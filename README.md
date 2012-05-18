DartExpress
===========

A simple, thin [expressjs](http://expressjs.com/) inspired layer around Dart's primitive HttpServer APIs. 
Also included is a single static file server module.

This library will eventually expand to help with other common usage patterns and features as and when needed.

Follow [@demisbellot](http://twitter.com/demisbellot) for updates.

## Download 

This will be made available on the Dart Package Manager when its ready, until then you can easily make use of this library by adding it as a submodule at your projects root:

    git submodule add git@github.com:mythz/DartExpress.git vendor/Express

Note: you can pull future updates on the client with a git pull in the submodule directory, e.g:

    cd vendor/Mixins
    git pull origin master    

If you prefer not to add a submodule you can just copy the single, stand-alone [Express.dart](https://github.com/mythz/DartExpress/blob/master/Express.dart) file. 

## Example Usage

This is an example of an Redis-powered REST backend Backbones.js demo TODO application:

      RedisClient client = new RedisClient();

      Express app = new Express();

      app.use(new StaticFileHandler());

      app.get("/todos", (HttpContext ctx){
        client.keys("todo:*").then((keys) =>
          client.mget(keys).then(ctx.sendJson)
        );
      });

      app.get("/todos/:id", (HttpContext ctx){
        var id = ctx.param("id");
        client.get("todo:$id}").then((todo) => todo != null ?
            ctx.sendJson(todo) :
            ctx.notFound("todo $id does not exist")
        );
      });

      app.post("/todos", (HttpContext ctx){
        ctx.readAsJson().then((x){
          client.incr("ids:todo").then((newId){
            var todo = $(x).defaults({"content":null,"done":false,"order":0});
            todo["id"] = newId;
            client.set("todo:$newId", todo);
            ctx.sendJson(todo);
          });
        });
      });

      app.put("/todos/:id", (HttpContext ctx){
        var id = ctx.param("id");
        ctx.readAsJson().then((todo){
          client.set("todo:$id", todo);
          ctx.sendJson(todo);
        });
      });

      app.delete("/todos/:id", (HttpContext ctx){
        client.del("todo:${ctx.param('id')}");
        ctx.send();
      });

      print("listening on 8000...");
      app.listen("127.0.0.1", 8000);

# API

Register encapsulated Modules like StaticFileHandler

    interface Module {
      void register(HttpServer server);
    }

The core Express API upon which all the Apps modules and request handlers are registered on
Calls the request handler of the first matching route with a HttpContext

    interface Express default _Express {
      Express();

      //Register a module to be used with this app
      void use(Module module);

      //Register a request handler that will be called for a matching GET request
      get(handlerMapping, RequestHandler handler);

      //Register a request handler that will be called for a matching POST request
      post(handlerMapping, RequestHandler handler);

      //Register a request handler that will be called for a matching PUT request
      put(handlerMapping, RequestHandler handler);

      //Register a request handler that will be called for a matching DELETE request
      delete(handlerMapping, RequestHandler handler);

      //Register a request handler that will be called for a matching PATCH request
      patch(handlerMapping, RequestHandler handler);

      //Register a request handler that will be called for a matching HEAD request
      head(handlerMapping, RequestHandler handler);

      //Register a request handler that will be called for a matching OPTIONS request
      options(handlerMapping, RequestHandler handler);

      // Register a request handler that handles ANY verb
      any(handlerMapping, RequestHandler handler);

      // Alias for registering a request handler matching ANY verb
      void operator []=(String handlerMapping, RequestHandler handler);

      bool handlesRequest(HttpRequest req);

      // Return true if this HttpRequest is a match for this verb and route
      bool isMatch(String verb, String route, HttpRequest req);

      // When all routes and modules are registered - Start the HttpServer on host:port
      void listen([String host, int port]);

A high-level object encapsulating both HttpRequest and HttpResponse objects
with useful overloads for each for common operations and usage patterns.

    interface HttpContext default _HttpContext {
      HttpContext(HttpRequest this.req, HttpResponse this.res, [String this.routePath]);

      //Context
      String routePath;
      HttpRequest  req;
      HttpResponse res;
      Map<String,String> params;
      String param(String name);

      //Read
      String get contentType();
      Future<List<int>> readAsBytes();
      Future<String> readAsText([Encoding encoding]);
      Future<Object> readAsJson([Encoding encoding]);
      Future<Object> readAsObject([Encoding encoding]);

      //Write
      String get responseContentType();
      void set responseContentType(String value);
      HttpContext head([int httpStatus, String statusReason, String contentType, Map<String,String> headers]);

      HttpContext write(Object value, [String contentType]);
      HttpContext writeText(String text);
      HttpContext writeBytes(List<int> bytes);

      void send([Object value, String contentType, int httpStatus, String statusReason]);
      void sendJson(Object value, [int httpStatus, String statusReason]);
      void sendHtml(Object value, [int httpStatus, String statusReason]);
      void sendText(Object value, [String contentType, int httpStatus, String statusReason]);
      void sendBytes(List<int> bytes, [String contentType, int httpStatus, String statusReason]);

      //Custom Status responses
      void notFound([String statusReason, Object value, String contentType]);
    }

The signature your Request Handlers should implement

    typedef void RequestHandler (HttpContext ctx);

## Modules

### StaticFileHandler

Serve static files for requests that don't match any defined routes:

      app.use(new StaticFileHandler());

## Contributors

  - [mythz](https://github.com/mythz) (Demis Bellot)

### Feedback 

Feedback and contributions are welcome.

