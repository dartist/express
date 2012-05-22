#library("RedisClient");
#import("dart:io");
#import("../vendor/Mixins/Mixin.dart");


class InMemoryRedisClient {

  Map<String,Object> _keys;

  InMemoryRedisClient() :
    _keys = new Map<String,Object>();

  Future<List<String>> keys(String pattern){
    Completer<List<String>> task = new Completer<List<String>>();
    List<String> matchingKeys = new List<String>();
    _keys.forEach((k,v){
      if (_globMatch(k, pattern)) matchingKeys.add(k);
    });
    task.complete(matchingKeys);
    return task.future;
  }

  Future<Object> get(String key) {
    Completer<Object> task = new Completer<List<Object>>();
    task.complete(_keys[key]);
    return task.future;
  }

  Future<List<Object>> mget(List<String> allKeys){
    Completer<Object> task = new Completer<List<Object>>();
    List<Object> values = [];
    allKeys.forEach((x){
      if (_keys.containsKey(x)) values.add(_keys[x]);
    });
    task.complete(values);
    return task.future;
  }

  Future set(String key, Object value){
    Completer task = new Completer();
    _keys[key] = value;
    task.complete(null);
    return task.future;
  }

  Future incr(String key){
    Completer task = new Completer();
    var counter = _keys[key];
    counter = counter == null ? 1 : Math.parseInt(counter.toString()) + 1;
    _keys[key] = counter;
    task.complete(counter);
    return task.future;
  }

  Future del(String key){
    Completer task = new Completer();
    _keys.remove(key);
    task.complete(null);
    return task.future;
  }
}

//very basic redis glob function - only supports '*' wildcard on start or end of pattern
bool _globMatch(String key, String withPattern) {
  bool startsWith = withPattern.endsWith("*");
  bool endsWith = withPattern.startsWith("*");
  bool contains = startsWith && endsWith;
  String pattern = withPattern.replaceAll(new RegExp("^\\*"),"").replaceAll(new RegExp("\\*\$"),"");

  return contains
      ? key.indexOf(pattern) >= 0
      : startsWith ?
        key.startsWith(pattern)
      : endsWith ?
        key.endsWith(pattern) :
        key == pattern;
}
