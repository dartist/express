library Express;
import "dart:io";
import "dart:json" as JSON;
import "dart:collection";
import "dart:typed_data";
import "dart:async";
import "package:dartmixins/mixin.dart";

/*
 * Register encapsulated Modules like StaticFileHandler
 */
abstract class Module {
  void register(Express server);
}

/* The core Express API upon which all the Apps modules and request handlers are registered on
 * Calls the request handler of the first matching route with a HttpContext
 */
abstract class Express {
  factory Express() = _Express;

  //Register a module to be used with this app
  Express use(Module module);

  //Register a request handler that will be called for a matching GET request
  Express get(String atRoute, RequestHandler handler);

  //Register a request handler that will be called for a matching POST request
  Express post(String atRoute, RequestHandler handler);

  //Register a request handler that will be called for a matching PUT request
  Express put(String atRoute, RequestHandler handler);

  //Register a request handler that will be called for a matching DELETE request
  Express delete(String atRoute, RequestHandler handler);

  //Register a request handler that will be called for a matching PATCH request
  Express patch(String atRoute, RequestHandler handler);

  //Register a request handler that will be called for a matching HEAD request
  Express head(String atRoute, RequestHandler handler);

  //Register a request handler that will be called for a matching OPTIONS request
  Express options(String atRoute, RequestHandler handler);

  //Register a request handler that handles ANY verb
  Express any(String atRoute, RequestHandler handler);
  
  //Register a custom request handler. Execute requestHandler, if matcher is true.
  //If priority < 0, custom handler will be executed before route handlers, otherwise after. 
  void addRequestHandler(bool matcher(HttpRequest req), void requestHandler(HttpContext ctx), {int priority:0});

  //Alias for registering a request handler matching ANY verb
  void operator []=(String atRoute, RequestHandler handler);

  //Can any of the registered routes handle this HttpRequest
  bool handlesRequest(HttpRequest req);

  // Return true if this HttpRequest is a match for this verb and route
  bool isMatch(String verb, String route, HttpRequest req);

  // When all routes and modules are registered - Start the HttpServer on host:port
  Future<HttpServer> listen([String host, int port]);
  
  /// Permanently stops this [HttpServer] from listening for new connections.
  /// This closes this [Stream] of [HttpRequest]s with a done event.
  void close();
}

/* A high-level object encapsulating both HttpRequest and HttpResponse objects
 * with useful overloads for each for common operations and usage patterns.
 */
abstract class HttpContext {
  factory HttpContext(HttpRequest req, [String routePath]) {
    return new _HttpContext(req, req.response, routePath);
  }

  //Context
  String routePath;
  HttpRequest  req;
  HttpResponse res;
  Map<String,String> get params;

  //Read
  String get contentType;
  Future<List<int>> readAsBytes();
  Future<String> readAsText([Encoding encoding]);
  Future<Object> readAsJson({Encoding encoding});
  Future<Object> readAsObject([Encoding encoding]);

  //Write
  String get responseContentType;
  void set responseContentType(String value);
  HttpContext head([int httpStatus, String statusReason, String contentType, Map<String,String> headers]);

  HttpContext write(Object value, {String contentType});
  HttpContext writeText(String text);
  HttpContext writeBytes(List<int> bytes);

  void send({Object value, String contentType, int httpStatus, String statusReason});
  void sendJson(Object value, {int httpStatus, String statusReason});
  void sendHtml(Object value, [int httpStatus, String statusReason]);
  void sendText(Object value, {String contentType, int httpStatus, String statusReason});
  void sendBytes(List<int> bytes, {String contentType, int httpStatus, String statusReason});

  //Custom Status responses
  void notFound([String statusReason, Object value, String contentType]);
}

// The signature your Request Handlers should implement
typedef void RequestHandler (HttpContext ctx);

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

class _HttpContext implements HttpContext {
  String routePath;
  String reqPath;
  RequestHandler handler;
  HttpRequest  req;
  HttpResponse res;
  Map<String,String> _params;
  String _format;

  _HttpContext(HttpRequest this.req, HttpResponse this.res, [String this.routePath]);

  Map<String,String> get params{
    if (_params == null){
      _params = $(pathMatcher(routePath, req.uri.path)).addAll(req.uri.queryParameters);
    }
    return _params;
  }

  Future<List<int>> readAsBytes() {
    var completer = new Completer<List<int>>();
    
    var buf = new Uint8List(req.contentLength);
    req.listen(buf.addAll)
    ..onError(completer.completeError)
    ..onDone((){      
      completer.complete(buf);
    });
      
    return completer.future;
  }

  Future<String> readAsText([Encoding encoding = Encoding.UTF_8]) {
    var completer = new Completer<String>();
    
    var buf = new StringBuffer();
    req
      .transform(new StringDecoder(encoding))
      .listen(buf.write)
      ..onError(completer.completeError)
      ..onDone((){      
        completer.complete(buf.toString());
      });
      
    return completer.future;
  }

  Future<Object> readAsJson({Encoding encoding: Encoding.UTF_8}) =>
      readAsText(encoding).then((json) => JSON.parse(json));

  Future<Object> readAsObject([Encoding encoding = Encoding.UTF_8]) =>
      readAsText(encoding).then((text) => ContentTypes.isJson(contentType)
           ? $(JSON.parse(text)).defaults(req.uri.queryParameters)
           : text
      );

  String _contentTypeOnly;
  String _contentType;
  String get contentType => _contentType != null ?
      _contentType
    : req.headers[HttpHeaders.CONTENT_TYPE] != null ?
      req.headers[HttpHeaders.CONTENT_TYPE][0] :
      null;

  String get responseContentType => _contentTypeOnly;

  void set responseContentType(String value) {
    if (value == null || value.isEmpty) return;
    res.headers.set(HttpHeaders.CONTENT_TYPE, value);
    _contentTypeOnly = $(value).splitOnFirst(";")[0];
  }

  HttpContext head([int httpStatus, String statusReason, String contentType, Map<String,String> headers]){
    if (httpStatus != null) {
      res.statusCode = httpStatus;
    }
    if (statusReason != null) {
      res.reasonPhrase = statusReason;
    }
    responseContentType = contentType;
    if (headers != null) {
      headers.forEach((name, value) => res.headers.set(name, value));
    }
    return this;
  }

  HttpContext write(Object value, {String contentType}){
    responseContentType = contentType;
    if (value != null){
      switch(_contentTypeOnly){
        case ContentTypes.JSON:
          res.write(JSON.stringify(value));
        break;
        default:
          if (value is List<int> || ContentTypes.isBinary(_contentTypeOnly)) {
            res.write(value);
          } else {
            res.write(value.toString());
          }
          break;
      }
    }
    return this;
  }

  HttpContext writeText(String text){
    res.write(text);
    return this;
  }

  HttpContext writeBytes(List<int> bytes){
    res.write(bytes);
    return this;
  }

  void send({Object value, String contentType, int httpStatus, String statusReason}){
    head(httpStatus, statusReason, contentType);
    if (value != null) write(value);
    res.close();
  }

  void sendJson(Object value, {int httpStatus, String statusReason}) =>
      send(value: value, contentType: ContentTypes.JSON, httpStatus: httpStatus, statusReason: statusReason);

  void sendHtml(Object value, [int httpStatus, String statusReason]) =>
      send(value: value, contentType: ContentTypes.HTML, httpStatus: httpStatus, statusReason: statusReason);

  void sendText(Object value, {String contentType, int httpStatus, String statusReason}){
    head(httpStatus, statusReason, contentType);
    if (value != null) res.write(value);
    res.close();
  }

  void sendBytes(List<int> bytes, {String contentType, int httpStatus, String statusReason}){
    head(httpStatus, statusReason, contentType);
    if (bytes != null) res.write(bytes);
    res.close();
  }

  void notFound([String statusReason, Object value, String contentType]) =>
      send(value: value, contentType: contentType, httpStatus: HttpStatus.NOT_FOUND, statusReason: statusReason);
}

class ContentTypes {
  static String _default;
  static void set defaultType(String contentType) { _default = contentType; }
  static String get defaultType => _default != null ? _default : HTML;

  static const String TEXT = "text/plain";
  static const String HTML = "text/html; charset=UTF-8";
  static const String CSS = "text/css";
  static const String JS = "application/javascript";
  static const String JSON = "application/json";
  static const String XML = "application/xml";
  static const String FORM_URL_ENCODED = "x-www-form-urlencoded";
  static const String MULTIPART_FORMDATA = "multipart/form-data";

  static bool isJson(String contentType) => matches(contentType, JSON);
  static bool isText(String contentType) => matches(contentType, TEXT);
  static bool isXml(String contentType) => matches(contentType, XML);
  static bool isFormUrlEncoded(String contentType) => matches(contentType, FORM_URL_ENCODED);
  static bool isMultipartFormData(String contentType) => matches(contentType, MULTIPART_FORMDATA);

  static Map<String, String> _extensionsMap;
  static Map<String, String> get extensionsMap {
    if (_extensionsMap == null) {
      _extensionsMap = {
         "txt" : ContentTypes.TEXT,
         "json": ContentTypes.JSON,
         "htm" : ContentTypes.HTML,
         "html": ContentTypes.HTML,
         "css" : ContentTypes.CSS,
         "js"  : ContentTypes.JS,
         "dart": "application/dart",
         "png" : "image/png",
         "gif" : "image/gif",
         "jpg" : "image/jpeg",
         "jpeg": "image/jpeg",
      };
    }
    return _extensionsMap;
  }

  static List<String> _binaryContentTypes;
  static List<String> get binaryContentTypes {
    if (_binaryContentTypes == null){
      _binaryContentTypes = ["image/jpeg","image/gif","image/png","application/octet"];
    }
    return _binaryContentTypes;
  }

  static String getContentType(File file) {
    String ext = file.path.split('.').last;
    return extensionsMap[ext];
  }

  static bool isBinary(String contentType) => binaryContentTypes.indexOf(contentType) >= 0;

  static bool matches(String contentType, String withContentType){
    if (contentType == null || withContentType == null) return false;
    return contentType.length > withContentType.length
        ? withContentType.startsWith(contentType)
        : contentType.startsWith(withContentType);
  }
}

class StaticFileHandler implements Module {

  void register(Express server) =>
      server.addRequestHandler((_) => true, (req) => execute(new HttpContext(req)));

  void execute(HttpContext ctx){
    String path = (ctx.req.uri.path.endsWith('/')) ? ".${ctx.req.uri.path}index.html" : ".${ctx.req.uri.path}";
    print("serving $path");

    File file = new File(path);
    file.exists().then((bool exists) {
      if (exists) {
        ctx.responseContentType = ContentTypes.getContentType(file);        
        file.fullPath().then((String fullPath) {
          file.openRead()
          .pipe(ctx.res)
          .catchError((e) { });
        });
      } else {
        ctx.notFound("$path not found on this server");
      }
    });
  }

}

bool routeMatches(String route, String matchesPath) => pathMatcher(route, matchesPath) != null;

Map<String,String> pathMatcher(String routePath, String matchesPath){
  Map params = {};
  if (routePath == matchesPath) return params;
  List<String> pathComponents = matchesPath.split("/");
  List<String> routeComponents = routePath.split("/");
  if (pathComponents.length == routeComponents.length){
    for (int i=0; i<pathComponents.length; i++){
      String path = pathComponents[i];
      String route = routeComponents[i];
      if (path == route) continue;
      if (route.startsWith(":")) {
        params[route.substring(1)] = path;
        continue;
      }
      return null;
    }
    return params;
  }
  return null;
}
