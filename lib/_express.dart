part of express;

typedef bool RequestHandlerMatcher (HttpRequest req);
typedef void ErrorHandler(e, stacktace, HttpContext req);

class RequestHandlerEntry {
  RequestHandlerMatcher matcher;
  RequestHandler handler;
  int priority;
  RequestHandlerEntry(this.matcher, this.handler, this.priority);
}

String __dirname = Directory.current.toString();

class _Express implements Express {
  Map<String, LinkedHashMap<String,Route>> _verbPaths;
  List<String> _verbs = const ["GET","POST","PUT","DELETE","PATCH","HEAD","OPTIONS","ANY"];
  List<Module> _modules;
  HttpServer server;
  List<RequestHandlerEntry> _customHandlers; 
  Map<String,String> configs = {};
  ErrorHandler errorHandler;

  _Express() {
    _verbPaths = new Map<String, LinkedHashMap<String,Route>>();
    _verbs.forEach((x) => _verbPaths[x] = {});
    _modules = new List<Module>();
    _customHandlers = new List<RequestHandlerEntry>();
    errorHandler = _errorHandler;
    config('basedir', __dirname);
    config('views', 'views');
  }

  Route _addHandler(String verb, String atRoute, [RequestHandler handler]){
    var route = new Route(atRoute, errorHandler);
    
    if(handler != null) {
      route.then(handler);
    }
    
    _verbPaths[verb][atRoute] = route;
    return route;
  }

  void config(String name, String value){
    configs[name] = value;
  }
  
  String getConfig(String name) =>
    configs[name];
  
  // Use this to add a module to your project
  Express use(Module module){
    _modules.add(module);
    return this;
  }

  Route get(String atRoute, [RequestHandler handler]) =>
      _addHandler("GET", atRoute, handler);

  Route post(String atRoute, [RequestHandler handler]) =>
      _addHandler("POST", atRoute, handler);

  Route put(String atRoute, [RequestHandler handler]) =>
      _addHandler("PUT", atRoute, handler);

  Route delete(String atRoute, [RequestHandler handler]) =>
      _addHandler("DELETE", atRoute, handler);

  Route patch(String atRoute, [RequestHandler handler]) =>
      _addHandler("PATCH", atRoute, handler);

  Route head(String atRoute, [RequestHandler handler]) =>
      _addHandler("HEAD", atRoute, handler);

  Route options(String atRoute, [RequestHandler handler]) =>
      _addHandler("OPTIONS", atRoute, handler);

  // Register a request handler that handles any verb
  Route any(String atRoute, [RequestHandler handler]) =>
      _addHandler("ANY", atRoute, handler);

  void operator []=(String atRoute, RequestHandler handler){
    any(atRoute, handler);
  }

  bool handlesRequest(HttpRequest req) {
    bool foundMatch = _verbPaths[req.method] != null &&
    ( _verbPaths[req.method].keys.any((x) => routeMatches(x, req.uri.path))
      || _verbPaths["ANY"].keys.any((x) => routeMatches(x, req.uri.path)) );
    if (foundMatch) print("match found for ${req.method} ${req.uri.path}");
    return foundMatch;
  }

  // Return true if this HttpRequest is a match for this verb and route
  bool isMatch(String verb, String route, HttpRequest req) =>
      (req.method == verb || verb == "ANY") && routeMatches(route, req.uri.path);

  void addRequestHandler(bool matcher(HttpRequest req), void requestHandler(HttpContext ctx), {int priority:0}) {
    _customHandlers.add(new RequestHandlerEntry(matcher, requestHandler, priority));
    _customHandlers.sort((x,y) => x.priority - y.priority);
  }
  
  Iterable<Formatter> get formatters => _modules.where((x) => x is Formatter); 

  void render(HttpContext ctx, String viewName, [dynamic viewModel]){
    for (var formatter in formatters){
      var result = formatter.render(ctx, viewModel, viewName);
      if (result != null){
        ctx.sendHtml(result);
      }
      if (ctx.closed) return;
    }
  }
  
  _errorHandler(e, stacktrace, HttpContext ctx){
    var error = stacktrace != null
      ? "$e\n\nStackTrace:\n$stacktrace"
      : e;
            
    try{
      if (!ctx.closed){
        ctx.sendText(error, contentType: ContentTypes.TEXT, 
            httpStatus: 500, statusReason: "Internal ServerError");
      }
    } catch(e){/*ignore*/}
    finally{
      ctx.end();
    }
    
    logError(error);
  }
  
  Future<HttpServer> listen([String host="127.0.0.1", int port=80]){
    return HttpServer.bind(host, port).then((HttpServer x) {
      server = x;
      _modules.forEach((module) => module.register(this));
      
      server.listen((HttpRequest req){
        var ctx = new HttpContext(this, req);

        try
        {
          for (RequestHandlerEntry customHandler in 
              _customHandlers.where((x) => x.priority < 0)){
            if (customHandler.matcher(req)){
              customHandler.handler(ctx);
              return;
            }            
          }
          
          for (var verb in _verbPaths.keys){
            var handlers = _verbPaths[verb];
            for (var route in handlers.keys){
              if (isMatch(verb, route, req)){
                logDebug("Handling $verb request to $route");
                var handler = handlers[route];
                ctx = new HttpContext(this, req, route);
                handler.handle(ctx);
                return;
              }
            }            
          }
  
          for (var formatter in formatters){
            var result = formatter.render(ctx, null);
            if (result != null){
              ctx.sendHtml(result);
              return;
            }
          }
          
          for (RequestHandlerEntry customHandler in _customHandlers
              .where((x) => x.priority >= 0)){
            if (customHandler.matcher(req)){
              customHandler.handler(ctx);
              return;
            }            
          }
        } catch(e, stacktrace){
          errorHandler(e, stacktrace, ctx);
        }
        
        new HttpContext(this, req).notFound("not found","'${req.uri.path}' was not found.");
      });
      
      logInfo("listening on http://$host:$port");
    });
  }
  
  void close() {
    server.close();
  }
}
