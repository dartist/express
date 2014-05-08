library build;

import "dart:io";
import "package:args/args.dart";
import "package:node_shims/path.dart" as path;
import "package:jaded/jaded.dart" as jade;

/*
 * Compile all .jade views in any directory that contain a 'jade.yaml' file.
 * To trigger this in your project add this to your projects /build.dart file:
 * 
 * import "package:express/express_build.dart";
 * main(){
 *   build();
 * }
 * 
 */

void build([List<String> args]){
  buildArgs = args != null ? args : [];
  
  processArgs();
  
//  if (cleanBuild) {
//    handleCleanCommand();
//  } else if (fullBuild) {
//    handleFullBuild();
//  } else {
//    handleChangedFiles(changedFiles);
//    handleRemovedFiles(removedFiles);
//  }

  var touchedFiles = changedFiles.toList()..addAll(removedFiles);
  if (cleanBuild 
      || fullBuild 
      || touchedFiles.any((x) => 
          x.endsWith("jade.yaml") || x.endsWith(".jade") || x.endsWith(".md")))
  {
    var yamlMarkers = [];

    Directory.current.list(recursive: true).listen((entity) {
      if (entity is File) {
        var file = entity as File;
        if (file.path.endsWith("jade.yaml"))
          yamlMarkers.add(file.path);
      }
    },
    onDone: () => handleYamlMarkers(yamlMarkers));
  }   
  
  // Return a non-zero code to indicate a build failure.
  //exit(1);
}

handleYamlMarkers(List<String> yamlMarkers){
  yamlMarkers.forEach((marker){
    var dirname = path.dirname(marker);
    Directory.current = dirname;
    var basedir = ".";
    var jadeTemplates = jade.renderDirectory(basedir);
    new File(path.join([dirname,"jade.views.dart"])).writeAsString(jadeTemplates);
  });
}

bool cleanBuild;
bool fullBuild;
bool useMachineInterface;

List<String> buildArgs;
List<String> changedFiles;
List<String> removedFiles;

/**
 * Handle --changed, --removed, --clean, --full, and --help command-line args.
 */
void processArgs() {
  var parser = new ArgParser();
  parser.addOption("changed", help: "the file has changed since the last build",
      allowMultiple: true);
  parser.addOption("removed", help: "the file was removed since the last build",
      allowMultiple: true);
  parser.addFlag("clean", negatable: false, help: "remove any build artifacts");
  parser.addFlag("full", negatable: false, help: "perform a full build");
  parser.addFlag("machine",
    negatable: false, help: "produce warnings in a machine parseable format");
  parser.addFlag("help", negatable: false, help: "display this help and exit");

  var args = parser.parse(buildArgs);

  if (args["help"]) {
    print(parser.getUsage());
    exit(0);
  }

  changedFiles = args["changed"];
  removedFiles = args["removed"];

  useMachineInterface = args["machine"];

  cleanBuild = args["clean"];
  fullBuild = args["full"];
}