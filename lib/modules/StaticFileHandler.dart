part of express;

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