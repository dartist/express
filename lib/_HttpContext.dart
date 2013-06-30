part of express;

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