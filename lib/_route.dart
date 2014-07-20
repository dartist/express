part of express;

class _Route implements Route {
  
  String atRoute;
  ErrorHandler errorHandler;
  Queue<RequestHandler> handlers;
  
  _Route(this.atRoute, this.errorHandler) {
    handlers = new Queue<RequestHandler>();
  }
  
  Route then(RequestHandler handler) {
    handlers.add(managedRequestHandler(handler));
    
    return this;
  }
  
  void handle(HttpContext ctx) {
    bool result = true;
    
    while(handlers.length > 0 && result) {
      RequestHandler handler = handlers.removeFirst();
      
      result = handler(ctx);
    }
  }
  
  managedRequestHandler(RequestHandler handler){
    return (HttpContext ctx){
      try {
        return handler(ctx);
      } catch (e, stacktrace){
        errorHandler(e, stacktrace, ctx);
      }
    };
  }
}