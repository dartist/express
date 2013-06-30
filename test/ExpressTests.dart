import "package:unittest/unittest.dart";
import "../lib/express.dart";
import "dart:io";
import "dart:async";
import "package:dartmixins/mixin.dart";
import "InMemoryRedisClient.dart";
import "package:json_client/json_client.dart";

main(){

  group("Express unit tests", (){
    
    test("hashCode test", (){
      var item = {"content":"new TODO","done":false,"order":0};
      var map = new Map<String,Object>();
      map["key"] = item;
      expect(map["key"], equals(item), reason:"can store an object in a map");
    });

    test("Express: routes", (){
      expect(pathMatcher("/tests", "/tests"), equals({}), reason:"matches exact path");
      expect(pathMatcher("/tests/:id", "/tests/1"), equals({'id':'1'}), reason:"matches path with arg");
      expect(pathMatcher("/users/:id/todos/:todoId", "/users/1/todos/2"), equals({'id':'1','todoId':'2'}), reason:"matches path with 2 args");
      expect(pathMatcher("/tests/:id", "/tests"), isNull, reason:"child path does not match parent route");
      expect(pathMatcher("/tests/:id", "/rests"), isNull, reason:"does not match invalid path");
      expect(pathMatcher("/todos", "/todos.css"), isNull, reason:"does not match same path with .css ext");
      expect(pathMatcher("/todos", "/todos.js"),  isNull, reason:"does not match same path with .js ext");
    });
    
  });
  
  group("Express Integration tests", (){
    Express app;
    InMemoryRedisClient redis;
    JsonClient client;

    setUp((){

      redis = new InMemoryRedisClient();
      client = new JsonClient("http://127.0.0.1:8000");

      app = new Express();

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
            todo != null 
              ? ctx.sendJson(todo) 
              : ctx.notFound("todo $id does not exist")
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

      return app.listen("127.0.0.1", 8000);
    });
    
    tearDown((){
      app.close();
    });
        
    test("Express: Todo App", (){
      client.todos({"content":"new TODO","done":false,"order":0}).then(expectAsync1((_){

        client.todos()
        .then(expectAsync1((todos){

          expect(todos.length, equals(1), reason:"expected 1 added TODO");
          expect(todos[0]['content'], equals("new TODO"), reason:"new TODO was not added");
          expect(todos[0]['id'], equals(1), reason:"new TODO id was not set");

          var id = todos[0]['id'];
          todos[0]['content'] = "updated TODO";
          client.put("/todos/$id", todos[0])
            .then(expectAsync1((_1){
              client.todos(id)
                .then(expectAsync1((todo){
                  expect(todo['content'], equals("updated TODO"), reason:"new TODO was not updated");

                  client.delete("/todos/$id")
                  .then(expectAsync1((_2){

                    cb(statusCode){
                      expect(statusCode, equals(404), reason:"Expected 404 - deleted TODO not found");
                    }

                    var future = client.todos(id);
                    future.then(cb).catchError(expectAsync1((HttpClientResponse e){
                      cb(e.statusCode);
                    }));

                  }));
                }));
            }));

        }));
        
      }));
    });

    test("Express: test app[route] handles all verbs", (){
      client.counter()
        .then(expectAsync1((counter) {
          expect(counter, equals(1), reason:"New counter starts at 1");
  
          client.counter({'force-POST':true})
            .then(expectAsync1((nextCounter){
              expect(nextCounter, equals(2), reason:"Next counter is 2");
            }));
        }));
    });
  
  });
}