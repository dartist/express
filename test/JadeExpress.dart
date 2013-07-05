import "dart:io";
import "package:jaded/jaded.dart";
import "../lib/express.dart";
import "views/jade.views.dart";

main(){
  int counter = 0;
  var app = new Express()
    ..use(new JadeViewEngine(viewTemplates:JADE_TEMPLATES))
    ..use(new StaticFileHandler("public"))
    
    ..get('/', (HttpContext ctx){
      ctx.render('index', {'title': 'Home'});
    })
  
    ..get('/counter', (HttpContext ctx){
      ctx.sendJson({'counter': counter++});
    });

 app.listen("127.0.0.1", 8000);
}