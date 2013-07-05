part of express;

class JadeViewEngine extends Formatter {
  Express express;
  
  Map<String,Function> viewTemplates;
  
  JadeViewEngine({this.viewTemplates}){
    
  }
  
  void register(Express server) {
    express = server;
  }
  
  String get ext => "jade";
  String get contentType => "text/html";
  String get viewsDir => express.getConfig('views');
  
  Future<bool> render(HttpContext ctx, dynamic viewModel, [String viewName]){   
    var completer = new Completer();
    var req = ctx.req;
    var relativePath = viewName != null
      ? "${viewName}.$ext"
      : "${req.uri.path}.$ext";
    var viewPath = join([viewsDir,relativePath]); 
      
    if (viewTemplates != null){
      var render = viewTemplates["./$relativePath"];
      if (render != null){
        try{
          var html = render(viewModel);
          ctx.sendHtml(html);
          completer.complete(true);
        }catch(e){
          completer.completeError(e);
        }
        return completer.future;
      }
    }

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