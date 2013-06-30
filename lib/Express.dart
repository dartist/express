library express;

import "dart:io";
import "dart:json" as JSON;
import "dart:collection";
import "dart:typed_data";
import "dart:async";
import "package:dartmixins/mixin.dart";

part "ContentTypes.dart";
part "_Express.dart";
part "_HttpContext.dart";
part "utils.dart";

part "modules/StaticFileHandler.dart";


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
  factory HttpContext(HttpRequest req, [String routePath]) =>
    new _HttpContext(req, req.response, routePath);

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
