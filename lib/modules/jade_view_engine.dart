part of express;

class JadeViewEngine extends Formatter {
  Express express;
  
  Map<String,Function> viewTemplates;
  Map<String,Function> publicTemplates;
  
  JadeViewEngine(this.viewTemplates, {this.publicTemplates}){}
  
  void register(Express server) {
    express = server;
  }
  
  String get ext => "jade";
  String get contentType => "text/html";
  String get viewsDir => express.getConfig('views');
  
  String render(HttpContext ctx, dynamic viewModel, [String viewName]){
    var relativePath = viewName != null
        ? "${viewName}.$ext"
        : "${trimStart(ctx.uri.path,'/')}.$ext";
    
    if (publicTemplates != null && viewModel == null && viewName == null){
      var render = publicTemplates["./$relativePath"];
      if (render != null){
        var req = ctx.req;
        viewModel = {
          'method': req.method,
          'uri': req.uri,
          'headers': req.headers,
          'request': req,
          'response': req.response,
        };
        var html = render(viewModel);
        return html;
      }
    }
    
    var render = viewTemplates["./$relativePath"];
    if (render != null){
      var html = render(viewModel);
      return html;
    }
    return null;
  }
  
  Future<String> renderAsync(HttpContext ctx, dynamic viewModel, [String viewName]){   
    var completer = new Completer();
    var req = ctx.req;
    var relativePath = viewName != null
      ? "${viewName}.$ext"
      : "${req.uri.path}.$ext";
    var viewPath = join([viewsDir,relativePath]); 
      
    var viewFile = new File(viewPath);
    viewFile.exists().then((isFile){
      if (isFile){
        jaded.renderFile(viewFile.path)
        .then((html){
          completer.complete(html);
        })
        .catchError(completer.completeError);
      }
      else {
        completer.complete(null);
      }
    });

    return completer.future;
  }
  
}