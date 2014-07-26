part of express;

class _Route implements Route {
  
  String atRoute;
  ErrorHandler errorHandler;
  Queue<RequestHandler> handlers;
  
  _Route(this.atRoute, this.errorHandler) {
    this.handlers = new Queue<RequestHandler>();
  }
  
  Route then(RequestHandler handler) {
    handlers.add(managedRequestHandler(handler));
    
    return this;
  }
  
  void handle(HttpContext ctx) {
    var result = true;
    var index = 0;
    
    // Iterate over the queue untill we handled them all or the result of the handler is false
    while(index < handlers.length && result) {
      var handler = handlers.elementAt(index++);
      
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