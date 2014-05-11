part of express;

bool routeMatches(String route, String matchesPath) => pathMatcher(route, matchesPath) != null;

Map<String,String> pathMatcher(String routePath, String matchesPath){
  Map params = {};
  if (routePath == matchesPath) return params;
  List<String> pathComponents = matchesPath.split("/");
  List<String> routeComponents = routePath.split("/");
  if (pathComponents.length == routeComponents.length){
    for (int i=0; i<pathComponents.length; i++){
      String path = pathComponents[i];
      String route = routeComponents[i];
      if (path == route) continue;
      if (route.startsWith(":")) {
        params[route.substring(1)] = path;
        continue;
      }
      return null;
    }
    return params;
  }
  return null;
}


class LogLevel {
  static const int NONE = 0;
  static const int ERROR = 1;
  static const int WARN = 2;
  static const int INFO = 3;
  static const int DEBUG = 4;
  static const int ALL = 5;
}

void logDebug (arg) {
  if (logLevel >= LogLevel.DEBUG) logger(arg, logtype: LogLevel.DEBUG);
}
void logInfo (arg) {
  if (logLevel >= LogLevel.INFO) logger(arg, logtype: LogLevel.INFO);
}
void logError (arg) {
  if (logLevel >= LogLevel.ERROR) logger(arg, logtype: LogLevel.ERROR);
}
void logWarn (arg) {
  if (logLevel >= LogLevel.WARN) logger(arg, logtype: LogLevel.WARN);
}



