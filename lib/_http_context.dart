part of express;

class _HttpContext extends Stream<List<int>> implements HttpContext, HttpRequest {
  String routePath;
  String reqPath;
  RequestHandler handler;
  HttpRequest  req;
  HttpResponse res;
  Map<String,String> _params;
  String _format;
  Express express;
  bool _closed = false;

  _HttpContext(this.express, this.req, this.res, [this.routePath]){
    res.done.then(
      (_) => _closed = true, onError: (_) => _closed = true);
  }
  
  //HttpRequest - allow HttpContext to be castable to HttpRequest if needed.
  StreamSubscription<List<int>> listen(void onData(List<int> event),
                                       {void onError(error),
                                        void onDone(),
                                        bool cancelOnError}) {
    return req.listen(onData,
                      onError: onError,
                      onDone: onDone,
                      cancelOnError: cancelOnError);
  }  
  
  Uri get uri => req.uri;
  
  Uri get requestedUri => req.requestedUri;

  String get method => req.method;

  HttpSession get session => req.session;

  HttpConnectionInfo get connectionInfo => req.connectionInfo;

  X509Certificate get certificate => req.certificate;
  
  List<Cookie> get cookies => req.cookies;
  
  HttpHeaders get headers => req.headers;
  
  bool get persistentConnection => req.persistentConnection;
  
  int get contentLength => req.contentLength;
  
  String get protocolVersion => req.protocolVersion;
  
  HttpResponse get response => req.response;
  //END HttpRequest  

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

  Future<String> readAsText([CONV.Encoding encoding = CONV.UTF8]) {
    var completer = new Completer<String>();
    
    var buf = new StringBuffer();
    req
      .transform(encoding.decoder)
      .listen(buf.write)
      ..onError(completer.completeError)
      ..onDone((){      
        completer.complete(buf.toString());
      });
      
    return completer.future;
  }

  Future<Object> readAsJson({CONV.Encoding encoding: CONV.UTF8}) =>
      readAsText(encoding).then((json) => CONV.JSON.decode(json));

  Future<Object> readAsObject([CONV.Encoding encoding = CONV.UTF8]) =>
      readAsText(encoding).then((text) => ContentTypes.isJson(contentType)
           ? $(CONV.JSON.decode(text)).defaults(req.uri.queryParameters)
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
          res.write(CONV.JSON.encode(value));
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
    end();
  }

  void sendJson(Object value, {int httpStatus, String statusReason}) =>
      send(value: value, contentType: ContentTypes.JSON, httpStatus: httpStatus, statusReason: statusReason);

  void sendHtml(Object value, [int httpStatus, String statusReason]) =>
      send(value: value, contentType: ContentTypes.HTML, httpStatus: httpStatus, statusReason: statusReason);

  void sendText(Object value, {String contentType, int httpStatus, String statusReason}){
    head(httpStatus, statusReason, contentType);
    if (value != null) res.write(value);
    end();
  }

  void sendBytes(List<int> bytes, {String contentType, int httpStatus, String statusReason}){
    head(httpStatus, statusReason, contentType);
    if (bytes != null) res.write(bytes);
    end();
  }

  void notFound([String statusReason, Object value, String contentType]) =>
      send(value: value, contentType: contentType, httpStatus: HttpStatus.NOT_FOUND, statusReason: statusReason);

  void render(String viewName, [dynamic viewModel]){
    express.render(this, viewName, viewModel);    
  }
  
  void end(){
    if (_closed) return;
    _closed = true;
    res.close();
  }
  
  bool get closed => _closed;
}