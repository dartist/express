import 'dart:isolate';
import 'package:jaded/runtime.dart';
import 'package:jaded/runtime.dart' as jade;

render(Map locals) { 
  jade.debug = [new Debug(lineno: 1, filename: "views/index.jade")];
try {
var filename = locals['filename'];
var title = locals['title'];
var cache = locals['cache'];

var buf = [];
var self = locals; 
if (self == null) self = {};
buf.add("<!DOCTYPE html><html><head><title>" + (jade.escape((jade.interp = title) == null ? '' : jade.interp)) + " - My Site</title><link rel=\"stylesheet\" href=\"/stylesheets/style.css\"></head><body><header><h1>My Site</h1></header><div class=\"container\"><div class=\"main-content\"><p>Vivamus hendrerit arcu sed erat molestie\nvehicula. Sed auctor neque eu tellus\nrhoncus ut eleifend nibh porttitor. Ut in.</p><p>Donec congue lacinia dui, a porttitor\nlectus condimentum laoreet. Nunc eu\nullamcorper orci. Quisque eget odio ac\nlectus vestibulum faucibus eget in metus.\nIn pellentesque faucibus vestibulum. Nulla\nat nulla justo, eget luctus tortor.</p></div><div class=\"sidebar\"><div class=\"widget\"><h1>Widget</h1><p>Sed auctor neque eu tellus rhoncus ut\neleifend nibh porttitor. Ut in nulla enim.</p><p>Vivamus hendrerit arcu sed erat molestie\nvehicula.</p></div></div></div><footer><p>Running on <a href=\"http://www.dartlang.org/\">dart </a>with <a href=\"https://github.com/dartist/express\">express </a>and <a href=\"https://github.com/dartist/jaded\">jaded </a></p></footer></body></html>");;
return buf.join("");

} catch (err) {
  jade.rethrows(err, jade.debug[0].filename, jade.debug[0].lineno);
} 
}

main() {
  port.receive((Map msg, SendPort replyTo) {
    if (msg["__shutdown"] == true) {
      port.close();
      return;
    }
    var html = render(msg);
    replyTo.send(html.toString());
  });
}
