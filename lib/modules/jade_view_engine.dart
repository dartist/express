part of express;

class JadeViewEngine extends Formatter {
  Express express;
  
  void register(Express server) {
    express = server;
  }
  
  String get ext => "jade";
  String get contentType => "text/html";
  String get viewsDir => express.getConfig('views');
  
  Future<bool> render(HttpContext ctx, dynamic viewModel, [String viewName]){   
    var completer = new Completer();
    var req = ctx.req;
    var viewPath = viewName != null
      ? join([viewsDir,"${viewName}.$ext"])
      : join([viewsDir,"${req.uri.path}.$ext"]);

      var viewFile = new File(viewPath);
      viewFile.exists().then((isFile){
        if (isFile){
          jaded.renderFile(viewFile.path)
          .then((html) {
            ctx.sendHtml(html);
          })
          .catchError(completer.completeError);
        }
        else {
          completer.complete(false);
        }
      });

    return completer.future;
  }
  
}