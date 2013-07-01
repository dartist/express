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

int logLevel = LogLevel.Info;

class LogLevel {
  static final int None = 0;
  static final int Error = 1;
  static final int Warn = 2;
  static final int Info = 3;
  static final int Debug = 4;
  static final int All = 5;
}

void logDebug (arg) {
  if (logLevel >= LogLevel.Debug) print(arg);
}
void logInfo (arg) {
  if (logLevel >= LogLevel.Info) print(arg);
}
void logError (arg) {
  if (logLevel >= LogLevel.Error) print(arg);
}
