part of express;

class JadeViewEngine extends Formatter {
  Express express;
  
  /// Render a .jade view from a route with ctx.render()
  Map<String,Function> views;  
  
  /// Execute a .jade view directly (i.e. without a route)
  Map<String,Function> pages;
  
  JadeViewEngine(this.views, {this.pages}){
    ext = "jade";
  }
  
  void register(Express server) {
    express = server;
  }
  
  String ext;
  String get contentType => "text/html";
  
  String render(HttpContext ctx, dynamic viewModel, [String viewName]){
    var relativePath = viewName != null
        ? "${viewName}.$ext"
        : "${trimStart(ctx.uri.path,'/')}.$ext";
    
    if (pages != null && viewModel == null && viewName == null){
      var render = pages["./$relativePath"];
      if (render != null){
        var req = ctx.req;
        //the 
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
    
    var render = views["./$relativePath"];
    if (render != null){
      var html = render(viewModel);
      return html;
    }
    return null;
  }

  String get viewsDir => express.getConfig('views');
  
  //Alternative way to compile and execute a .jade view at runtime via an isolate 
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