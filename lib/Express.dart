library Express;
import "dart:io";
import "dart:json";
import "dart:scalarlist";
import "package:dartmixins/mixin.dart";

/*
 * Register encapsulated Modules like StaticFileHandler
 */
abstract class Module {
  void register(HttpServer server);
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

  //Alias for registering a request handler matching ANY verb
  void operator []=(String atRoute, RequestHandler handler);

  //Can any of the registered routes handle this HttpRequest
  bool handlesRequest(HttpRequest req);

  // Return true if this HttpRequest is a match for this verb and route
  bool isMatch(String verb, String route, HttpRequest req);

  // When all routes and modules are registered - Start the HttpServer on host:port
  void listen([String host, int port]);
}

/* A high-level object encapsulating both HttpRequest and HttpResponse objects
 * with useful overloads for each for common operations and usage patterns.
 */
abstract class HttpContext {
  factory HttpContext(HttpRequest req, HttpResponse res, [String routePath]) {
    return new _HttpContext(req, res, routePath);
  }

  //Context
  String routePath;
  HttpRequest  req;
  HttpResponse res;
  Map<String,String> params;

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

class _Express implements Express {
  Map<String, LinkedHashMap<String,RequestHandler>> _verbPaths;
  List<String> _verbs = const ["GET","POST","PUT","DELETE","PATCH","HEAD","OPTIONS","ANY"];
  List<Module> _modules;
  HttpServer server;

  _Express() {
    _verbPaths = new Map<String, LinkedHashMap<String,RequestHandler>>();
    _verbs.forEach((x) => _verbPaths[x] = {});
    _modules = new List<Module>();
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
    ( _verbPaths[req.method].keys.some((x) => routeMatches(x, req.path))
      || _verbPaths["ANY"].keys.some((x) => routeMatches(x, req.path)) );
    if (foundMatch) print("match found for ${req.method} ${req.path}");
    return foundMatch;
  }

  // Return true if this HttpRequest is a match for this verb and route
  bool isMatch(String verb, String route, HttpRequest req) =>
      (req.method == verb || verb == "ANY") && routeMatches(route, req.path);

  void listen([String host="127.0.0.1", int port=80]){
    server = new HttpServer();
    _verbPaths.forEach((verb, handlers) =>
        handlers.forEach((route, handler) =>
            server.addRequestHandler((HttpRequest req) => isMatch(verb, route, req),
              (HttpRequest req, HttpResponse res) { handler(new HttpContext(req, res, route)); }
            )
        )
    );
    _modules.forEach((module) => module.register(server));
    server.listen(host, port);
  }
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
      _params = $(pathMatcher(routePath, req.path)).addAll(req.queryParameters);
    }
    return _params;
  }

  Future<List<int>> readAsBytes() {
    Completer<List<int>> completer = new Completer<List<int>>();
    var stream = req.inputStream;
    var chunks = new _BufferList();
    stream.onClosed = () {
      completer.complete(chunks.readBytes(chunks.length));
    };
    stream.onData = () {
      var chunk = stream.read();
      chunks.add(chunk);
    };
    stream.onError = completer.completeException;
    return completer.future;
  }

  Future<String> readAsText([Encoding encoding = Encoding.UTF_8]) {
//    var decoder = _StringDecoders.decoder(encoding);
    return readAsBytes().transform((bytes) {
      return new String.fromCharCodes(bytes);
//      decoder.write(bytes);
//      return decoder.decoded;
    });
  }

  Future<Object> readAsJson({Encoding encoding: Encoding.UTF_8}) =>
      readAsText(encoding).transform((json) => JSON.parse(json));

  Future<Object> readAsObject([Encoding encoding = Encoding.UTF_8]) =>
      readAsText(encoding).transform((text) => ContentTypes.isJson(contentType)
           ? $(JSON.parse(text)).defaults(req.queryParameters)
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
          res.outputStream.writeString(JSON.stringify(value));
        break;
        default:
          if (value is List<int> || ContentTypes.isBinary(_contentTypeOnly)) {
            res.outputStream.write(value);
          } else {
            res.outputStream.writeString(value.toString());
          }
          break;
      }
    }
    return this;
  }

  HttpContext writeText(String text){
    res.outputStream.writeString(text);
    return this;
  }

  HttpContext writeBytes(List<int> bytes){
    res.outputStream.write(bytes);
    return this;
  }

  void send({Object value, String contentType, int httpStatus, String statusReason}){
    head(httpStatus, statusReason, contentType);
    if (value != null) write(value);
    res.outputStream.close();
  }

  void sendJson(Object value, {int httpStatus, String statusReason}) =>
      send(value: value, contentType: ContentTypes.JSON, httpStatus: httpStatus, statusReason: statusReason);

  void sendHtml(Object value, [int httpStatus, String statusReason]) =>
      send(value: value, contentType: ContentTypes.HTML, httpStatus: httpStatus, statusReason: statusReason);

  void sendText(Object value, {String contentType, int httpStatus, String statusReason}){
    head(httpStatus, statusReason, contentType);
    if (value != null) res.outputStream.writeString(value);
    res.outputStream.close();
  }

  void sendBytes(List<int> bytes, {String contentType, int httpStatus, String statusReason}){
    head(httpStatus, statusReason, contentType);
    if (bytes != null) res.outputStream.write(bytes);
    res.outputStream.close();
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
    String ext = file.name.split('.').last;
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

  void register(HttpServer server) =>
      server.addRequestHandler((_) => true, (req, res) => execute(new HttpContext(req, res)));

  void execute(HttpContext ctx){
    String path = (ctx.req.path.endsWith('/')) ? ".${ctx.req.path}index.html" : ".${ctx.req.path}";
    print("serving $path");

    File file = new File(path);
    file.exists().then((bool exists) {
      if (exists) {
        ctx.responseContentType = ContentTypes.getContentType(file);
        if (ContentTypes.isBinary(ctx.responseContentType)){
          file.readAsBytes().then(ctx.sendBytes);
        } else {
          file.readAsString().then(ctx.sendText);
        }
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

class _BufferList {
  _BufferList() {
    clear();
  }

  void add(List<int> buffer, {int offset: 0}) {
    assert(offset == 0 || _buffers.isEmpty);
    _buffers.addLast(buffer);
    _length += buffer.length;
    if (offset != 0) _index = offset;
  }

  List<int> get first => _buffers.first;

  int get index =>  _index;

  int peek() => _buffers.first[_index];

  int next() {
    int value = _buffers.first[_index++];
    _length--;
    if (_index == _buffers.first.length) {
      _buffers.removeFirst();
      _index = 0;
    }
    return value;
  }

  List<int> readBytes(int count) {
    List<int> result;
    if (_length == 0 || _length < count) return null;
    if (_index == 0 && _buffers.first.length == count) {
      result = _buffers.first;
      _buffers.removeFirst();
      _index = 0;
      _length -= count;
      return result;
    } else {
      int firstRemaining = _buffers.first.length - _index;
      if (firstRemaining >= count) {
        result = _buffers.first.getRange(_index, count);
        _index += count;
        _length -= count;
        if (_index == _buffers.first.length) {
          _buffers.removeFirst();
          _index = 0;
        }
        return result;
      } else {
        result = new Uint8List(count);
        int remaining = count;
        while (remaining > 0) {
          int bytesInFirst = _buffers.first.length - _index;
          if (bytesInFirst <= remaining) {
            result.setRange(count - remaining,
                            bytesInFirst,
                            _buffers.first,
                            _index);
            _buffers.removeFirst();
            _index = 0;
            _length -= bytesInFirst;
            remaining -= bytesInFirst;
          } else {
            result.setRange(count - remaining,
                            remaining,
                            _buffers.first,
                            _index);
            _index = remaining;
            _length -= remaining;
            remaining = 0;
            assert(_index < _buffers.first.length);
          }
        }
        return result;
      }
    }
  }

  void removeBytes(int count) {
    int firstRemaining = first.length - _index;
    assert(count <= firstRemaining);
    if (count == firstRemaining) {
      _buffers.removeFirst();
      _index = 0;
    } else {
      _index += count;
    }
    _length -= count;
  }

  int get length => _length;

  bool isEmpty() => _buffers.isEmpty;

  void clear() {
    _index = 0;
    _length = 0;
    _buffers = new Queue();
  }

  int _length;  // Total number of bytes remaining in the buffers.
  Queue<List<int>> _buffers;  // List of data buffers.
  int _index;  // Index of the next byte in the first buffer.
}
