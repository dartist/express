import 'package:jaded/runtime.dart';
import 'package:jaded/runtime.dart' as jade;
Map<String,Function> JADE_TEMPLATES = {
'./index.jade': ([Map locals]){///jade-begin
  if (locals == null) locals = {};
  var title = locals['title'];

var buf = [];
var self = locals; 
if (self == null) self = {};
buf.add("<!DOCTYPE html><html><head><title>" + (jade.escape((jade.interp = title) == null ? '' : jade.interp)) + " - My Site</title><link rel=\"stylesheet\" href=\"/stylesheets/style.css\"></head><body><header><h1>My Site</h1></header><div class=\"container\"><div class=\"main-content\"><p>Vivamus hendrerit arcu sed erat molestie\nvehicula. Sed auctor neque eu tellus\nrhoncus ut eleifend nibh porttitor. Ut in.</p><p>Donec congue lacinia dui, a porttitor\nlectus condimentum laoreet. Nunc eu\nullamcorper orci. Quisque eget odio ac\nlectus vestibulum faucibus eget in metus.\nIn pellentesque faucibus vestibulum. Nulla\nat nulla justo, eget luctus tortor.</p></div><div class=\"sidebar\"><div class=\"widget\"><h1>Widget</h1><p>Sed auctor neque eu tellus rhoncus ut\neleifend nibh porttitor. Ut in nulla enim.</p><p>Vivamus hendrerit arcu sed erat molestie\nvehicula.</p></div></div></div><footer><p>Running on <a href=\"http://www.dartlang.org/\">dart </a>with <a href=\"https://github.com/dartist/express\">express </a>and <a href=\"https://github.com/dartist/jaded\">jaded </a></p></footer></body></html>");;
return buf.join("");

},///jade-end
'./layout.jade': ([Map locals]){///jade-begin
  if (locals == null) locals = {};
  var title = locals['title'];

var buf = [];
var self = locals; 
if (self == null) self = {};
buf.add("<!DOCTYPE html><html><head><title>" + (jade.escape((jade.interp = title) == null ? '' : jade.interp)) + " - My Site</title><link rel=\"stylesheet\" href=\"/stylesheets/style.css\"></head><body><header><h1>My Site</h1></header><div class=\"container\"><div class=\"main-content\"></div><div class=\"sidebar\"></div></div><footer><p>Running on <a href=\"http://www.dartlang.org/\">dart </a>with <a href=\"https://github.com/dartist/express\">express </a>and <a href=\"https://github.com/dartist/jaded\">jaded </a></p></footer></body></html>");;
return buf.join("");

},///jade-end
'./sub/app-layout.jade': ([Map locals]){///jade-begin
  if (locals == null) locals = {};
  
var buf = [];
var self = locals; 
if (self == null) self = {};
buf.add("<html><script src=\"vendor/jquery.js\"></script><script src=\"vendor/caustic.js\"></script><script src=\"app.js\"></script><body></body></html>");;
return buf.join("");

},///jade-end
'./sub/layout.jade': ([Map locals]){///jade-begin
  if (locals == null) locals = {};
  
var buf = [];
var self = locals; 
if (self == null) self = {};
buf.add("<html><script src=\"vendor/jquery.js\"></script><script src=\"vendor/caustic.js\"></script><body></body></html>");;
return buf.join("");

},///jade-end
'./sub/page.jade': ([Map locals]){///jade-begin
  if (locals == null) locals = {};
  
var buf = [];
var self = locals; 
if (self == null) self = {};
buf.add("<html><script src=\"vendor/jquery.js\"></script><script src=\"vendor/caustic.js\"></script><script src=\"app.js\"></script><script src=\"foo.js\"></script><script src=\"bar.js\"></script><body></body></html>");;
return buf.join("");

},///jade-end
'./sub/sub2/perf.jade': ([Map locals]){///jade-begin
  if (locals == null) locals = {};
  var report = locals['report'];
var chp, sec, page;

var buf = [];
var self = locals; 
if (self == null) self = {};
buf.add("<div class=\"data\"> <ol id=\"contents\" class=\"sortable\">");
// iterate report
;((){
  var $$obj = report;
  if ($$obj is Iterable) {

    for (var $index = 0, $$l = $$obj.length; $index < $$l; $index++) {
      var item = $$obj[$index];

if ( (item.parent != null))
{
buf.add("<div><li" + (jade.attrs({ 'data-ref':(item.id), "class": [('chapter')] }, {"class":false,"data-ref":true})) + "><a" + (jade.attrs({ 'href':('/admin/report/detail/' + item.id) }, {"href":true})) + ">" + (jade.escape(null == (jade.interp = item.name) ? "" : jade.interp)) + "</a></li>");
chp = item.id;
{
buf.add("<ol class=\"sortable\">");
// iterate report
;((){
  var $$obj = report;
  if ($$obj is Iterable) {

    for (var $index = 0, $$l = $$obj.length; $index < $$l; $index++) {
      var item = $$obj[$index];

if ( (item.parent == chp && item.type == 'section'))
{
buf.add("<div><li" + (jade.attrs({ 'data-ref':(item.id), "class": [('section')] }, {"class":false,"data-ref":true})) + "><a" + (jade.attrs({ 'href':('/admin/report/detail/' + item.id) }, {"href":true})) + ">" + (jade.escape(null == (jade.interp = item.name) ? "" : jade.interp)) + "</a></li>");
sec = item.id;
{
buf.add("<ol class=\"sortable\">");
// iterate report
;((){
  var $$obj = report;
  if ($$obj is Iterable) {

    for (var $index = 0, $$l = $$obj.length; $index < $$l; $index++) {
      var item = $$obj[$index];

if ( (item.parent == sec && item.type == 'page'))
{
buf.add("<div><li" + (jade.attrs({ 'data-ref':(item.id), "class": [('page')] }, {"class":false,"data-ref":true})) + "><a" + (jade.attrs({ 'href':('/admin/report/detail/' + item.id) }, {"href":true})) + ">" + (jade.escape(null == (jade.interp = item.name) ? "" : jade.interp)) + "</a></li>");
page = item.id;
{
buf.add("<ol class=\"sortable\">");
// iterate report
;((){
  var $$obj = report;
  if ($$obj is Iterable) {

    for (var $index = 0, $$l = $$obj.length; $index < $$l; $index++) {
      var item = $$obj[$index];

if ( (item.parent == page && item.type == 'subpage'))
{
buf.add("<div><li" + (jade.attrs({ 'data-ref':(item.id), "class": [('subpage')] }, {"class":false,"data-ref":true})) + "><a" + (jade.attrs({ 'href':('/admin/report/detail/' + item.id) }, {"href":true})) + ">" + (jade.escape(null == (jade.interp = item.name) ? "" : jade.interp)) + "</a></li></div>");
}
    }

  } else {
    var $$l = 0;
    for (var $index in $$obj.keys) {
      $$l++;      var item = $$obj[$index];

if ( (item.parent == page && item.type == 'subpage'))
{
buf.add("<div><li" + (jade.attrs({ 'data-ref':(item.id), "class": [('subpage')] }, {"class":false,"data-ref":true})) + "><a" + (jade.attrs({ 'href':('/admin/report/detail/' + item.id) }, {"href":true})) + ">" + (jade.escape(null == (jade.interp = item.name) ? "" : jade.interp)) + "</a></li></div>");
}
    }

  }
})();

buf.add("</ol>");
}
buf.add("</div>");
}
    }

  } else {
    var $$l = 0;
    for (var $index in $$obj.keys) {
      $$l++;      var item = $$obj[$index];

if ( (item.parent == sec && item.type == 'page'))
{
buf.add("<div><li" + (jade.attrs({ 'data-ref':(item.id), "class": [('page')] }, {"class":false,"data-ref":true})) + "><a" + (jade.attrs({ 'href':('/admin/report/detail/' + item.id) }, {"href":true})) + ">" + (jade.escape(null == (jade.interp = item.name) ? "" : jade.interp)) + "</a></li>");
page = item.id;
{
buf.add("<ol class=\"sortable\">");
// iterate report
;((){
  var $$obj = report;
  if ($$obj is Iterable) {

    for (var $index = 0, $$l = $$obj.length; $index < $$l; $index++) {
      var item = $$obj[$index];

if ( (item.parent == page && item.type == 'subpage'))
{
buf.add("<div><li" + (jade.attrs({ 'data-ref':(item.id), "class": [('subpage')] }, {"class":false,"data-ref":true})) + "><a" + (jade.attrs({ 'href':('/admin/report/detail/' + item.id) }, {"href":true})) + ">" + (jade.escape(null == (jade.interp = item.name) ? "" : jade.interp)) + "</a></li></div>");
}
    }

  } else {
    var $$l = 0;
    for (var $index in $$obj.keys) {
      $$l++;      var item = $$obj[$index];

if ( (item.parent == page && item.type == 'subpage'))
{
buf.add("<div><li" + (jade.attrs({ 'data-ref':(item.id), "class": [('subpage')] }, {"class":false,"data-ref":true})) + "><a" + (jade.attrs({ 'href':('/admin/report/detail/' + item.id) }, {"href":true})) + ">" + (jade.escape(null == (jade.interp = item.name) ? "" : jade.interp)) + "</a></li></div>");
}
    }

  }
})();

buf.add("</ol>");
}
buf.add("</div>");
}
    }

  }
})();

buf.add("</ol>");
}
buf.add("</div>");
}
    }

  } else {
    var $$l = 0;
    for (var $index in $$obj.keys) {
      $$l++;      var item = $$obj[$index];

if ( (item.parent == chp && item.type == 'section'))
{
buf.add("<div><li" + (jade.attrs({ 'data-ref':(item.id), "class": [('section')] }, {"class":false,"data-ref":true})) + "><a" + (jade.attrs({ 'href':('/admin/report/detail/' + item.id) }, {"href":true})) + ">" + (jade.escape(null == (jade.interp = item.name) ? "" : jade.interp)) + "</a></li>");
sec = item.id;
{
buf.add("<ol class=\"sortable\">");
// iterate report
;((){
  var $$obj = report;
  if ($$obj is Iterable) {

    for (var $index = 0, $$l = $$obj.length; $index < $$l; $index++) {
      var item = $$obj[$index];

if ( (item.parent == sec && item.type == 'page'))
{
buf.add("<div><li" + (jade.attrs({ 'data-ref':(item.id), "class": [('page')] }, {"class":false,"data-ref":true})) + "><a" + (jade.attrs({ 'href':('/admin/report/detail/' + item.id) }, {"href":true})) + ">" + (jade.escape(null == (jade.interp = item.name) ? "" : jade.interp)) + "</a></li>");
page = item.id;
{
buf.add("<ol class=\"sortable\">");
// iterate report
;((){
  var $$obj = report;
  if ($$obj is Iterable) {

    for (var $index = 0, $$l = $$obj.length; $index < $$l; $index++) {
      var item = $$obj[$index];

if ( (item.parent == page && item.type == 'subpage'))
{
buf.add("<div><li" + (jade.attrs({ 'data-ref':(item.id), "class": [('subpage')] }, {"class":false,"data-ref":true})) + "><a" + (jade.attrs({ 'href':('/admin/report/detail/' + item.id) }, {"href":true})) + ">" + (jade.escape(null == (jade.interp = item.name) ? "" : jade.interp)) + "</a></li></div>");
}
    }

  } else {
    var $$l = 0;
    for (var $index in $$obj.keys) {
      $$l++;      var item = $$obj[$index];

if ( (item.parent == page && item.type == 'subpage'))
{
buf.add("<div><li" + (jade.attrs({ 'data-ref':(item.id), "class": [('subpage')] }, {"class":false,"data-ref":true})) + "><a" + (jade.attrs({ 'href':('/admin/report/detail/' + item.id) }, {"href":true})) + ">" + (jade.escape(null == (jade.interp = item.name) ? "" : jade.interp)) + "</a></li></div>");
}
    }

  }
})();

buf.add("</ol>");
}
buf.add("</div>");
}
    }

  } else {
    var $$l = 0;
    for (var $index in $$obj.keys) {
      $$l++;      var item = $$obj[$index];

if ( (item.parent == sec && item.type == 'page'))
{
buf.add("<div><li" + (jade.attrs({ 'data-ref':(item.id), "class": [('page')] }, {"class":false,"data-ref":true})) + "><a" + (jade.attrs({ 'href':('/admin/report/detail/' + item.id) }, {"href":true})) + ">" + (jade.escape(null == (jade.interp = item.name) ? "" : jade.interp)) + "</a></li>");
page = item.id;
{
buf.add("<ol class=\"sortable\">");
// iterate report
;((){
  var $$obj = report;
  if ($$obj is Iterable) {

    for (var $index = 0, $$l = $$obj.length; $index < $$l; $index++) {
      var item = $$obj[$index];

if ( (item.parent == page && item.type == 'subpage'))
{
buf.add("<div><li" + (jade.attrs({ 'data-ref':(item.id), "class": [('subpage')] }, {"class":false,"data-ref":true})) + "><a" + (jade.attrs({ 'href':('/admin/report/detail/' + item.id) }, {"href":true})) + ">" + (jade.escape(null == (jade.interp = item.name) ? "" : jade.interp)) + "</a></li></div>");
}
    }

  } else {
    var $$l = 0;
    for (var $index in $$obj.keys) {
      $$l++;      var item = $$obj[$index];

if ( (item.parent == page && item.type == 'subpage'))
{
buf.add("<div><li" + (jade.attrs({ 'data-ref':(item.id), "class": [('subpage')] }, {"class":false,"data-ref":true})) + "><a" + (jade.attrs({ 'href':('/admin/report/detail/' + item.id) }, {"href":true})) + ">" + (jade.escape(null == (jade.interp = item.name) ? "" : jade.interp)) + "</a></li></div>");
}
    }

  }
})();

buf.add("</ol>");
}
buf.add("</div>");
}
    }

  }
})();

buf.add("</ol>");
}
buf.add("</div>");
}
    }

  }
})();

buf.add("</ol>");
}
buf.add("</div>");
}
    }

  } else {
    var $$l = 0;
    for (var $index in $$obj.keys) {
      $$l++;      var item = $$obj[$index];

if ( (item.parent != null))
{
buf.add("<div><li" + (jade.attrs({ 'data-ref':(item.id), "class": [('chapter')] }, {"class":false,"data-ref":true})) + "><a" + (jade.attrs({ 'href':('/admin/report/detail/' + item.id) }, {"href":true})) + ">" + (jade.escape(null == (jade.interp = item.name) ? "" : jade.interp)) + "</a></li>");
chp = item.id;
{
buf.add("<ol class=\"sortable\">");
// iterate report
;((){
  var $$obj = report;
  if ($$obj is Iterable) {

    for (var $index = 0, $$l = $$obj.length; $index < $$l; $index++) {
      var item = $$obj[$index];

if ( (item.parent == chp && item.type == 'section'))
{
buf.add("<div><li" + (jade.attrs({ 'data-ref':(item.id), "class": [('section')] }, {"class":false,"data-ref":true})) + "><a" + (jade.attrs({ 'href':('/admin/report/detail/' + item.id) }, {"href":true})) + ">" + (jade.escape(null == (jade.interp = item.name) ? "" : jade.interp)) + "</a></li>");
sec = item.id;
{
buf.add("<ol class=\"sortable\">");
// iterate report
;((){
  var $$obj = report;
  if ($$obj is Iterable) {

    for (var $index = 0, $$l = $$obj.length; $index < $$l; $index++) {
      var item = $$obj[$index];

if ( (item.parent == sec && item.type == 'page'))
{
buf.add("<div><li" + (jade.attrs({ 'data-ref':(item.id), "class": [('page')] }, {"class":false,"data-ref":true})) + "><a" + (jade.attrs({ 'href':('/admin/report/detail/' + item.id) }, {"href":true})) + ">" + (jade.escape(null == (jade.interp = item.name) ? "" : jade.interp)) + "</a></li>");
page = item.id;
{
buf.add("<ol class=\"sortable\">");
// iterate report
;((){
  var $$obj = report;
  if ($$obj is Iterable) {

    for (var $index = 0, $$l = $$obj.length; $index < $$l; $index++) {
      var item = $$obj[$index];

if ( (item.parent == page && item.type == 'subpage'))
{
buf.add("<div><li" + (jade.attrs({ 'data-ref':(item.id), "class": [('subpage')] }, {"class":false,"data-ref":true})) + "><a" + (jade.attrs({ 'href':('/admin/report/detail/' + item.id) }, {"href":true})) + ">" + (jade.escape(null == (jade.interp = item.name) ? "" : jade.interp)) + "</a></li></div>");
}
    }

  } else {
    var $$l = 0;
    for (var $index in $$obj.keys) {
      $$l++;      var item = $$obj[$index];

if ( (item.parent == page && item.type == 'subpage'))
{
buf.add("<div><li" + (jade.attrs({ 'data-ref':(item.id), "class": [('subpage')] }, {"class":false,"data-ref":true})) + "><a" + (jade.attrs({ 'href':('/admin/report/detail/' + item.id) }, {"href":true})) + ">" + (jade.escape(null == (jade.interp = item.name) ? "" : jade.interp)) + "</a></li></div>");
}
    }

  }
})();

buf.add("</ol>");
}
buf.add("</div>");
}
    }

  } else {
    var $$l = 0;
    for (var $index in $$obj.keys) {
      $$l++;      var item = $$obj[$index];

if ( (item.parent == sec && item.type == 'page'))
{
buf.add("<div><li" + (jade.attrs({ 'data-ref':(item.id), "class": [('page')] }, {"class":false,"data-ref":true})) + "><a" + (jade.attrs({ 'href':('/admin/report/detail/' + item.id) }, {"href":true})) + ">" + (jade.escape(null == (jade.interp = item.name) ? "" : jade.interp)) + "</a></li>");
page = item.id;
{
buf.add("<ol class=\"sortable\">");
// iterate report
;((){
  var $$obj = report;
  if ($$obj is Iterable) {

    for (var $index = 0, $$l = $$obj.length; $index < $$l; $index++) {
      var item = $$obj[$index];

if ( (item.parent == page && item.type == 'subpage'))
{
buf.add("<div><li" + (jade.attrs({ 'data-ref':(item.id), "class": [('subpage')] }, {"class":false,"data-ref":true})) + "><a" + (jade.attrs({ 'href':('/admin/report/detail/' + item.id) }, {"href":true})) + ">" + (jade.escape(null == (jade.interp = item.name) ? "" : jade.interp)) + "</a></li></div>");
}
    }

  } else {
    var $$l = 0;
    for (var $index in $$obj.keys) {
      $$l++;      var item = $$obj[$index];

if ( (item.parent == page && item.type == 'subpage'))
{
buf.add("<div><li" + (jade.attrs({ 'data-ref':(item.id), "class": [('subpage')] }, {"class":false,"data-ref":true})) + "><a" + (jade.attrs({ 'href':('/admin/report/detail/' + item.id) }, {"href":true})) + ">" + (jade.escape(null == (jade.interp = item.name) ? "" : jade.interp)) + "</a></li></div>");
}
    }

  }
})();

buf.add("</ol>");
}
buf.add("</div>");
}
    }

  }
})();

buf.add("</ol>");
}
buf.add("</div>");
}
    }

  } else {
    var $$l = 0;
    for (var $index in $$obj.keys) {
      $$l++;      var item = $$obj[$index];

if ( (item.parent == chp && item.type == 'section'))
{
buf.add("<div><li" + (jade.attrs({ 'data-ref':(item.id), "class": [('section')] }, {"class":false,"data-ref":true})) + "><a" + (jade.attrs({ 'href':('/admin/report/detail/' + item.id) }, {"href":true})) + ">" + (jade.escape(null == (jade.interp = item.name) ? "" : jade.interp)) + "</a></li>");
sec = item.id;
{
buf.add("<ol class=\"sortable\">");
// iterate report
;((){
  var $$obj = report;
  if ($$obj is Iterable) {

    for (var $index = 0, $$l = $$obj.length; $index < $$l; $index++) {
      var item = $$obj[$index];

if ( (item.parent == sec && item.type == 'page'))
{
buf.add("<div><li" + (jade.attrs({ 'data-ref':(item.id), "class": [('page')] }, {"class":false,"data-ref":true})) + "><a" + (jade.attrs({ 'href':('/admin/report/detail/' + item.id) }, {"href":true})) + ">" + (jade.escape(null == (jade.interp = item.name) ? "" : jade.interp)) + "</a></li>");
page = item.id;
{
buf.add("<ol class=\"sortable\">");
// iterate report
;((){
  var $$obj = report;
  if ($$obj is Iterable) {

    for (var $index = 0, $$l = $$obj.length; $index < $$l; $index++) {
      var item = $$obj[$index];

if ( (item.parent == page && item.type == 'subpage'))
{
buf.add("<div><li" + (jade.attrs({ 'data-ref':(item.id), "class": [('subpage')] }, {"class":false,"data-ref":true})) + "><a" + (jade.attrs({ 'href':('/admin/report/detail/' + item.id) }, {"href":true})) + ">" + (jade.escape(null == (jade.interp = item.name) ? "" : jade.interp)) + "</a></li></div>");
}
    }

  } else {
    var $$l = 0;
    for (var $index in $$obj.keys) {
      $$l++;      var item = $$obj[$index];

if ( (item.parent == page && item.type == 'subpage'))
{
buf.add("<div><li" + (jade.attrs({ 'data-ref':(item.id), "class": [('subpage')] }, {"class":false,"data-ref":true})) + "><a" + (jade.attrs({ 'href':('/admin/report/detail/' + item.id) }, {"href":true})) + ">" + (jade.escape(null == (jade.interp = item.name) ? "" : jade.interp)) + "</a></li></div>");
}
    }

  }
})();

buf.add("</ol>");
}
buf.add("</div>");
}
    }

  } else {
    var $$l = 0;
    for (var $index in $$obj.keys) {
      $$l++;      var item = $$obj[$index];

if ( (item.parent == sec && item.type == 'page'))
{
buf.add("<div><li" + (jade.attrs({ 'data-ref':(item.id), "class": [('page')] }, {"class":false,"data-ref":true})) + "><a" + (jade.attrs({ 'href':('/admin/report/detail/' + item.id) }, {"href":true})) + ">" + (jade.escape(null == (jade.interp = item.name) ? "" : jade.interp)) + "</a></li>");
page = item.id;
{
buf.add("<ol class=\"sortable\">");
// iterate report
;((){
  var $$obj = report;
  if ($$obj is Iterable) {

    for (var $index = 0, $$l = $$obj.length; $index < $$l; $index++) {
      var item = $$obj[$index];

if ( (item.parent == page && item.type == 'subpage'))
{
buf.add("<div><li" + (jade.attrs({ 'data-ref':(item.id), "class": [('subpage')] }, {"class":false,"data-ref":true})) + "><a" + (jade.attrs({ 'href':('/admin/report/detail/' + item.id) }, {"href":true})) + ">" + (jade.escape(null == (jade.interp = item.name) ? "" : jade.interp)) + "</a></li></div>");
}
    }

  } else {
    var $$l = 0;
    for (var $index in $$obj.keys) {
      $$l++;      var item = $$obj[$index];

if ( (item.parent == page && item.type == 'subpage'))
{
buf.add("<div><li" + (jade.attrs({ 'data-ref':(item.id), "class": [('subpage')] }, {"class":false,"data-ref":true})) + "><a" + (jade.attrs({ 'href':('/admin/report/detail/' + item.id) }, {"href":true})) + ">" + (jade.escape(null == (jade.interp = item.name) ? "" : jade.interp)) + "</a></li></div>");
}
    }

  }
})();

buf.add("</ol>");
}
buf.add("</div>");
}
    }

  }
})();

buf.add("</ol>");
}
buf.add("</div>");
}
    }

  }
})();

buf.add("</ol>");
}
buf.add("</div>");
}
    }

  }
})();

buf.add("</ol></div>");;
return buf.join("");

},///jade-end
'./sub/sub2/scripts.jade': ([Map locals]){///jade-begin
  if (locals == null) locals = {};
  
var buf = [];
var self = locals; 
if (self == null) self = {};
buf.add("<script src=\"/jquery.js\"></script><script src=\"/caustic.js\"></script>");;
return buf.join("");

},///jade-end
'./test.jade': ([Map locals]){///jade-begin
  if (locals == null) locals = {};
  var title = locals['title'];

var buf = [];
var self = locals; 
if (self == null) self = {};
buf.add("<!DOCTYPE html><html><head><title>" + (jade.escape((jade.interp = title) == null ? '' : jade.interp)) + " - My Site</title><link rel=\"stylesheet\" href=\"/stylesheets/style.css\"></head><body><header><h1>My Site</h1></header><div class=\"container\"><div class=\"main-content\"><p>Vivamus hendrerit arcu sed erat molestie\nvehicula. Sed auctor neque eu tellus\nrhoncus ut eleifend nibh porttitor. Ut in.</p><p>Donec congue lacinia dui, a porttitor\nlectus condimentum laoreet. Nunc eu\nullamcorper orci. Quisque eget odio ac\nlectus vestibulum faucibus eget in metus.\nIn pellentesque faucibus vestibulum. Nulla\nat nulla justo, eget luctus tortor.</p></div><div class=\"sidebar\"><div class=\"widget\"><h1>Widget</h1><p>Sed auctor neque eu tellus rhoncus ut\neleifend nibh porttitor. Ut in nulla enim.</p><p>Vivamus hendrerit arcu sed erat molestie\nvehicula.</p></div></div></div><footer><p>Running on <a href=\"http://www.dartlang.org/\">dart </a>with <a href=\"https://github.com/dartist/express\">express </a>and <a href=\"https://github.com/dartist/jaded\">jaded </a></p></footer></body></html>");;
return buf.join("");

},///jade-end
};
