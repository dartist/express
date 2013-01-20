library ExpressTests;
import "dart:io";
import "DUnit.dart";
import "package:dartmixins/mixin.dart";
import "package:express/Express.dart";
import "InMemoryRedisClient.dart";
import "JsonClient.dart";

ExpressTests() {

  module("Express");

  test("hashCode test", (){
    var item = {"content":"new TODO","done":false,"order":0};
    Map<String,Object> map = new Map<String,Object>();
    map["key"] = item;
    deepEqual(map["key"], item, "can store an object in a map");
  });

  test("Express: routes", (){
    deepEqual(pathMatcher("/tests", "/tests"), {}, "matches exact path");
    deepEqual(pathMatcher("/tests/:id", "/tests/1"), {'id':'1'}, "matches path with arg");
    deepEqual(pathMatcher("/users/:id/todos/:todoId", "/users/1/todos/2"), {'id':'1','todoId':'2'}, "matches path with 2 args");
    isNull(pathMatcher("/tests/:id", "/tests"), "child path does not match parent route");
    isNull(pathMatcher("/tests/:id", "/rests"), "does not match invalid path");
    isNull(pathMatcher("/todos", "/todos.css"), "does not match same path with .css ext");
    isNull(pathMatcher("/todos", "/todos.js"), "does not match same path with .js ext");
  });


  InMemoryRedisClient redis = new InMemoryRedisClient();
  var client = new JsonClient("http://127.0.0.1:8000");

  Express app = new Express();

  app["/counter"] = (HttpContext ctx){
    redis.incr("counter").then((nextIncr) =>
        ctx.sendJson(nextIncr)
    );
  };

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
    })
    .listen("127.0.0.1", 8000);

  asyncTest("Express: Todo App", (){
    client.todos({"content":"new TODO","done":false,"order":0}, (_){

      client.todos()
        .then((todos){

          equal(todos.length, 1, "expected 1 added TODO");
          equal(todos[0]['content'], "new TODO", "new TODO was not added");
          equal(todos[0]['id'], 1, "new TODO id was not set");

          var id = todos[0]['id'];
          todos[0]['content'] = "updated TODO";
          client.put("/todos/$id", todos[0])
            .then((_1){
              client.todos(id)
                .then((todo){
                  equal(todo['content'], "updated TODO", "new TODO was not updated");

                  client.delete("/todos/$id")
                  .then((_2){

                    cb(statusCode){
                      equal(statusCode, 404, "Expected 404 - deleted TODO not found");
                      start();
                    }

                    var future = client.todos(id);
                    future.then(cb);
                    future.handleException((HttpClientResponse e){
                      cb(e.statusCode);
                      return true;
                    });

                  });
                });
            });

        });
    });
  });

  asyncTest("Express: test app[route] handles all verbs", (){
    client.counter()
      .then((counter) {
        equal(counter, 1, "New counter starts at 1");

        client.counter({'force-POST':true})
          .then((nextCounter){
            equal(nextCounter, 2, "Next counter is 2");
            start();
          });
      });
  });

}
