part of express;

class ContentTypes {
  static String _default;
  static void set defaultType(String contentType) { _default = contentType; }
  static String get defaultType => _default != null ? _default : HTML;

  static const String TEXT = "text/plain";
  static const String HTML = "text/html; charset=UTF-8";
  static const String CSS = "text/css";
  static const String JS = "application/javascript";
  static const String JSON = "application/json";
  static const String XML = "application/xml";
  static const String FORM_URL_ENCODED = "x-www-form-urlencoded";
  static const String MULTIPART_FORMDATA = "multipart/form-data";

  static bool isJson(String contentType) => matches(contentType, JSON);
  static bool isText(String contentType) => matches(contentType, TEXT);
  static bool isXml(String contentType) => matches(contentType, XML);
  static bool isFormUrlEncoded(String contentType) => matches(contentType, FORM_URL_ENCODED);
  static bool isMultipartFormData(String contentType) => matches(contentType, MULTIPART_FORMDATA);

  static Map<String, String> _extensionsMap;
  static Map<String, String> get extensionsMap {
    if (_extensionsMap == null) {
      _extensionsMap = {
         "txt" : ContentTypes.TEXT,
         "json": ContentTypes.JSON,
         "htm" : ContentTypes.HTML,
         "html": ContentTypes.HTML,
         "css" : ContentTypes.CSS,
         "js"  : ContentTypes.JS,
         "dart": "application/dart",
         "png" : "image/png",
         "gif" : "image/gif",
         "jpg" : "image/jpeg",
         "jpeg": "image/jpeg",
      };
    }
    return _extensionsMap;
  }

  static List<String> _binaryContentTypes;
  static List<String> get binaryContentTypes {
    if (_binaryContentTypes == null){
      _binaryContentTypes = ["image/jpeg","image/gif","image/png","application/octet"];
    }
    return _binaryContentTypes;
  }

  static String getContentType(File file) {
    String ext = file.path.split('.').last;
    return extensionsMap[ext];
  }

  static bool isBinary(String contentType) => binaryContentTypes.indexOf(contentType) >= 0;

  static bool matches(String contentType, String withContentType){
    if (contentType == null || withContentType == null) return false;
    return contentType.length > withContentType.length
        ? withContentType.startsWith(contentType)
        : contentType.startsWith(withContentType);
  }
}