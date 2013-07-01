DartExpress
===========

A simple, thin [expressjs](http://expressjs.com/) inspired layer around Dart's primitive HttpServer APIs. 
Also included is a single static file server module.

This library will eventually expand to help with other common usage patterns and features as and when needed.

Follow [@demisbellot](http://twitter.com/demisbellot) for updates.

## Download 

This will be made available on the Dart Package Manager when its ready, until then you can easily make use of this library by adding it as a submodule at your projects root:

    git submodule add git@github.com:Dartist/Express.git vendor/Express
    cd vendor/Express
    git submodule init
    git submodule update    

Then you can pull future project updates with a git pull in the submodule directory, e.g:

    git pull origin master    

If you prefer not to add a submodule you can just copy the single, stand-alone [Express.dart](https://github.com/Dartist/Express/blob/master/Express.dart) file. 

## Example Usage

This is an example of an Redis-powered REST backend Backbones.js demo TODO application:

```dart
var client = new RedisClient();

var app = new Express();
app
  .use(new StaticFileHandler())

  .get("/todos", (HttpContext ctx){
    redis.keys("todo:*").then((keys) =>
      redis.mget(keys).then(ctx.sendJson)
    );
  })
  
  .get("/todos/:id", (HttpContext ctx){
    var id = ctx.params["id"];
    redis.get("todo:$id").then((todo) =>
      todo != null ?
        ctx.sendJson(todo) :
        ctx.notFound("todo $id does not exist")
    );
  })
  
  .post("/todos", (HttpContext ctx){
    ctx.readAsJson().then((x){
      redis.incr("ids:todo").then((newId){
        var todo = $(x).defaults({"content":null,"done":false,"order":0});
        todo["id"] = newId;
        redis.set("todo:$newId", todo);
        ctx.sendJson(todo);
      });
    });
  })
  
  .put("/todos/:id", (HttpContext ctx){
    var id = ctx.params["id"];
    ctx.readAsJson().then((todo){
      redis.set("todo:$id", todo);
      ctx.sendJson(todo);
    });
  })
  
  .delete("/todos/:id", (HttpContext ctx){
    redis.del("todo:${ctx.params['id']}");
    ctx.send();
  });
  
  app.listen("127.0.0.1", 8000);
```

# API

Register encapsulated Modules like StaticFileHandler

```dart
abstract class Module {
  void register(Express server);
}
```

The signature your Request Handlers should implement:

```dart
typedef void RequestHandler (HttpContext ctx);
```

The core Express API where all your Apps modules and request handlers are registered on.
Then when the server has started, the request handler of the first matching route found will be executed.

```dart
abstract class Express {

  //Gets a config setting
  String getConfig(String name);
  
  //Sets a config setting
  void setConfig(String name, String value);

  //Register a module to be used with this app
  Express use(Module module);

  //Register a request handler that will be called for a matching GET request
  Express get(String atRoute, RequestHandler handler);

  //Register a request handler that will be called for a matching POST request
  Express post(String atRoute, RequestHandler handler);

  //Register a request handler that will be called for a matching PUT request
  Express put(String atRoute, RequestHandler handler);

  //Register a request handler that will be called for a matching DELETE request
  Express delete(String atRoute, RequestHandler handler);

  //Register a request handler that will be called for a matching PATCH request
  Express patch(String atRoute, RequestHandler handler);

  //Register a request handler that will be called for a matching HEAD request
  Express head(String atRoute, RequestHandler handler);

  //Register a request handler that will be called for a matching OPTIONS request
  Express options(String atRoute, RequestHandler handler);

  //Register a request handler that handles ANY verb
  Express any(String atRoute, RequestHandler handler);
  
  //Register a custom request handler. Execute requestHandler, if matcher is true.
  //If priority < 0, custom handler will be executed before route handlers, otherwise after. 
  void addRequestHandler(bool matcher(HttpRequest req), void requestHandler(HttpContext ctx), {int priority:0});

  //Alias for registering a request handler matching ANY verb
  void operator []=(String atRoute, RequestHandler handler);

  //Can any of the registered routes handle this HttpRequest
  bool handlesRequest(HttpRequest req);

  // Return true if this HttpRequest is a match for this verb and route
  bool isMatch(String verb, String route, HttpRequest req);

  // When all routes and modules are registered - Start the HttpServer on host:port
  Future<HttpServer> listen([String host, int port]);
  
  /// Permanently stops this [HttpServer] from listening for new connections.
  /// This closes this [Stream] of [HttpRequest]s with a done event.
  void close();
}
```

A high-level object encapsulating both HttpRequest and HttpResponse objects providing useful overloads for common operations and usage patterns.

```dart
abstract class HttpContext {

  //Context
  String routePath;
  HttpRequest  req;
  HttpResponse res;
  Map<String,String> get params;

  //Read
  String get contentType;
  Future<List<int>> readAsBytes();
  Future<String> readAsText([Encoding encoding]);
  Future<Object> readAsJson({Encoding encoding});
  Future<Object> readAsObject([Encoding encoding]);

  //Write
  String get responseContentType;
  void set responseContentType(String value);
  HttpContext head([int httpStatus, String statusReason, String contentType, Map<String,String> headers]);

  HttpContext write(Object value, {String contentType});
  HttpContext writeText(String text);
  HttpContext writeBytes(List<int> bytes);

  void send({Object value, String contentType, int httpStatus, String statusReason});
  void sendJson(Object value, {int httpStatus, String statusReason});
  void sendHtml(Object value, [int httpStatus, String statusReason]);
  void sendText(Object value, {String contentType, int httpStatus, String statusReason});
  void sendBytes(List<int> bytes, {String contentType, int httpStatus, String statusReason});

  //Custom Status responses
  void notFound([String statusReason, Object value, String contentType]);
}
```

## Modules

### StaticFileHandler

Serve static files for requests that don't match any defined routes:

```dart
app.use(new StaticFileHandler());
```

-----

## Contributors

  - [mythz](https://github.com/mythz) (Demis Bellot)
  - [financeCoding](https://github.com/financeCoding) (Adam Singer)
