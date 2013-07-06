import "package:express/express_build.dart";

import "dart:io";
import "package:node_shims/path.dart" as path;

main(){
  print(Directory.current.path);
  print(Directory.current.path.split(Platform.pathSeparator).last);
  print(r"te$t-.p_th".replaceAll(new RegExp(r"[^a-zA-Z0-9_\$]"), "_"));
  
//  build(["--full"]);
}