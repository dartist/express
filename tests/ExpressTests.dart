#library("ExpressTests");
#import("../vendor/Mixins/DUnit.dart");
#import("../vendor/Mixins/Mixin.dart");
#import("../Express.dart");

ExpressTests() {

  module("Express");

  test("Express: routes", (){
    deepEqual(pathMatcher("/tests", "/tests"), {}, "matches exact path");
    deepEqual(pathMatcher("/tests/:id", "/tests/1"), {'id':'1'}, "matches path with arg");
    isNull(pathMatcher("/tests/:id", "/tests"), "child path does not match parent route");
    isNull(pathMatcher("/tests/:id", "/rests"), "does not match invalid path");
    isNull(pathMatcher("/todos", "/todos.css"), "does not match same path with .css ext");
    isNull(pathMatcher("/todos", "/todos.js"), "does not match same path with .js ext");
    deepEqual(pathMatcher("/users/:id/todos/:todoId", "/users/1/todos/2"), {'id':'1','todoId':'2'}, "matches path with 2 args");
  });

  test("Express: ", (){

  });
}
