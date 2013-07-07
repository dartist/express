import "dart:io";
import "package:jaded/jaded.dart";
import "package:express/express.dart";
import "views/jade.views.dart" as views;
import "public/jade.views.dart" as public;

main(){
  int counter = 0;
  var app = new Express()
    ..use(new JadeViewEngine(views.JADE_TEMPLATES, pages:public.JADE_TEMPLATES))
    ..use(new StaticFileHandler("public"))
    
    ..get('/', (HttpContext ctx){
      ctx.render('index', {'title': 'Home'});
    })
  
    ..get('/error', (HttpContext ctx){
      throw new ArgumentError("Custom User Error");
    })
  
    ..get('/counter', (HttpContext ctx){
      ctx.sendJson({'counter': counter++});
    });

  app.listen("127.0.0.1", 8000);
}