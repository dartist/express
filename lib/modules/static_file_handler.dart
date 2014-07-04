part of express;

class StaticFileHandler implements Module {
  String atPath;
  
  StaticFileHandler([this.atPath]);
  
  List<String> defaultDocuments = ["index.html"];

  void register(Express server) =>
    server.addRequestHandler((req) => true, 
    (ctx) => execute(ctx));

  String relativePath(String reqPath){
    if (reqPath == null) return null;
    if (reqPath.startsWith("/") && atPath == null)
      reqPath = "." + reqPath;
    
    String path = atPath != null 
      ? join([atPath, reqPath])
      : reqPath;

    if (path.endsWith(Platform.pathSeparator)){
      path += defaultDocuments.first;
    }
    
    return path;
  }
  
  void execute(HttpContext ctx){
    String path = relativePath(ctx.req.uri.path);
    
    logDebug("serving $path");

    File file = new File(path);
    file.exists().then((bool exists) {
      if (exists) {
        ctx.responseContentType = ContentTypes.getContentType(file);        
        file.openRead()
        .pipe(ctx.res)
        .catchError((e) { 
          ctx.sendText("error sending '$path': $e", 
            contentType: "text/plain", httpStatus: 500, statusReason:"static file error"); 
        });
      } else {
        ctx.notFound("static file not found", "'$path' was not found on this server.");
      }
    });
  }

}