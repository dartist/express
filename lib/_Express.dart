part of express;

typedef bool RequestHandlerMatcher (HttpRequest req);

class RequestHandlerEntry {
  RequestHandlerMatcher matcher;
  RequestHandler handler;
  int priority;
  RequestHandlerEntry(this.matcher, this.handler, this.priority);
}

class _Express implements Express {
  Map<String, LinkedHashMap<String,RequestHandler>> _verbPaths;
  List<String> _verbs = const ["GET","POST","PUT","DELETE","PATCH","HEAD","OPTIONS","ANY"];
  List<Module> _modules;
  HttpServer server;
  List<RequestHandlerEntry> _customHandlers; 

  _Express() {
    _verbPaths = new Map<String, LinkedHashMap<String,RequestHandler>>();
    _verbs.forEach((x) => _verbPaths[x] = {});
    _modules = new List<Module>();
    _customHandlers = new List<RequestHandlerEntry>();
  }

  Express _addHandler(String verb, String atRoute, RequestHandler handler){
    _verbPaths[verb][atRoute] = handler;
    return this;
  }

  // Use this to add a module to your project
  Express use(Module module){
    _modules.add(module);
    return this;
  }

  Express get(String atRoute, RequestHandler handler) =>
      _addHandler("GET", atRoute, handler);

  Express post(String atRoute, RequestHandler handler) =>
      _addHandler("POST", atRoute, handler);

  Express put(String atRoute, RequestHandler handler) =>
      _addHandler("PUT", atRoute, handler);

  Express delete(String atRoute, RequestHandler handler) =>
      _addHandler("DELETE", atRoute, handler);

  Express patch(String atRoute, RequestHandler handler) =>
      _addHandler("PATCH", atRoute, handler);

  Express head(String atRoute, RequestHandler handler) =>
      _addHandler("HEAD", atRoute, handler);

  Express options(String atRoute, RequestHandler handler) =>
      _addHandler("OPTIONS", atRoute, handler);

  // Register a request handler that handles any verb
  Express any(String atRoute, RequestHandler handler) =>
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
  }
  
  Future<HttpServer> listen([String host="127.0.0.1", int port=80]){
    return HttpServer.bind(host, port).then((HttpServer x) {
      server = x;
      _modules.forEach((module) => module.register(this));
      
      server.listen((HttpRequest req){
        for (RequestHandlerEntry customHandler in _customHandlers
            .where((x) => x.priority < 0)){
          if (customHandler.matcher(req)){
            customHandler.handler(req);
            return;
          }            
        }
        
        for (var verb in _verbPaths.keys){
          var handlers = _verbPaths[verb];
          for (var route in handlers.keys){
            if (isMatch(verb, route, req)){
              var handler = handlers[route];              
              handler(new HttpContext(req, route));
              return;
            }
          }            
        }
        
        for (RequestHandlerEntry customHandler in _customHandlers
            .where((x) => x.priority >= 0)){
          if (customHandler.matcher(req)){
            customHandler.handler(req);
            return;
          }            
        }
      });
    });
  }
  
  void close() =>
    server.close();
}