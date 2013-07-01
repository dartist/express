library path;

/// Some path utils similar to http://nodejs.org/api/path.html 

String trimStart(String str, String start) {
  if (str.startsWith(start) && str.length > start.length) {
    return str.substring(start.length);
  }
  return str;
}

String join(List paths){
  var sb = new StringBuffer();
  bool endsWithSlash = false;
  for (var oPath in paths){
    if (oPath == null) continue;
    String path = oPath.toString();
    if (path.isEmpty) continue;
    
    if (sb.length > 0 && !endsWithSlash)
      sb.write('/');
    
    String sanitizedPath = trimStart(path.replaceAll("\\", "/"), "/");
    sb.write(sanitizedPath);
    endsWithSlash = sanitizedPath.endsWith("/");
  }
  return sb.toString();
}

String dirname(String path){
  if (path == null || path.isEmpty) return null;
  var pos = path.lastIndexOf('/');
  return path.substring(0, pos);
}

String basename(String path, [String trimExt]){
  if (path == null || path.isEmpty) return null;
  var pos = path.lastIndexOf('/');
  var basename = path.substring(pos + 1);
  return trimExt != null && basename.endsWith(trimExt)
    ? basename.substring(0, basename.length - trimExt.length)
    : basename;   
}

String extname(String path){
  var extPos = path.lastIndexOf('.');
  if (extPos == -1) return '';
  return path.substring(extPos);
}
