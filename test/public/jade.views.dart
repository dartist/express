library jade_public;
import 'package:jaded/runtime.dart';
import 'package:jaded/runtime.dart' as jade;
Map<String,Function> JADE_TEMPLATES = {
'./layout.jade': ([Map locals]){///jade-begin
  if (locals == null) locals = {};
  var title = locals['title'];

var buf = [];
var self = locals; 
if (self == null) self = {};
buf.add("<!DOCTYPE html><html><head><title>" + (jade.escape((jade.interp = title) == null ? '' : jade.interp)) + " - Public Site</title><link rel=\"stylesheet\" href=\"/stylesheets/style.css\"></head><body><header><h1>Public Page</h1></header><div class=\"container\"><div class=\"main-content\"></div><div class=\"sidebar\"></div></div><footer><p>Running on <a href=\"http://www.dartlang.org/\">dart </a>with <a href=\"https://github.com/dartist/express\">express </a>and <a href=\"https://github.com/dartist/jaded\">jaded </a></p></footer></body></html>");;
return buf.join("");

},///jade-end
'./page.jade': ([Map locals]){///jade-begin
  if (locals == null) locals = {};
  var title = locals['title'];
var method = locals['method'];
var uri = locals['uri'];

var buf = [];
var self = locals; 
if (self == null) self = {};
buf.add("<!DOCTYPE html><html><head><title>" + (jade.escape((jade.interp = title) == null ? '' : jade.interp)) + " - Public Site</title><link rel=\"stylesheet\" href=\"/stylesheets/style.css\"></head><body><header><h1>Public Page</h1></header><div class=\"container\"><div class=\"main-content\"><p>This is a public page called directly\nvehicula. Sed auctor neque eu tellus\nrhoncus ut eleifend nibh porttitor. Ut in.</p><p>Donec congue lacinia dui, a porttitor\nlectus condimentum laoreet. Nunc eu\nullamcorper orci. Quisque eget odio ac\nlectus vestibulum faucibus eget in metus.\nIn pellentesque faucibus vestibulum. Nulla\nat nulla justo, eget luctus tortor.</p><h3>Request Info </h3><p><ol><li>method: " + (jade.escape((jade.interp = method) == null ? '' : jade.interp)) + " </li><li>uri: " + (jade.escape((jade.interp = uri) == null ? '' : jade.interp)) + "</li></ol></p></div><div class=\"sidebar\"><div class=\"widget\"><h1>Widget</h1><p>Sed auctor neque eu tellus rhoncus ut\neleifend nibh porttitor. Ut in nulla enim.</p><p>Vivamus hendrerit arcu sed erat molestie\nvehicula.</p></div></div></div><footer><p>Running on <a href=\"http://www.dartlang.org/\">dart </a>with <a href=\"https://github.com/dartist/express\">express </a>and <a href=\"https://github.com/dartist/jaded\">jaded </a></p></footer></body></html>");;
return buf.join("");

},///jade-end
};
