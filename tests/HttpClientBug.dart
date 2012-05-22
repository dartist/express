#import("dart:io");
#import("dart:json");

main() {
  HttpServer server = new HttpServer();
  int i = 0;
  server.addRequestHandler((HttpRequest req) => true,
    (HttpRequest req, HttpResponse res) {
      res.headers.set(HttpHeaders.CONTENT_TYPE, "text/plain");
      String out = "${req.path}: PONG ${i++}";
      res.contentLength = out.length;
      res.outputStream.writeString(out);
      res.outputStream.close();
    });
  server.listen("127.0.0.1", 8000);


  HttpClient client1 = new HttpClient();
  HttpClientConnection conn1 = client1.open('POST', "127.0.0.1", 8000, '/test');
  handleRequest(conn1, "POST", (){

    handleResponse(client1, conn1, (){
      HttpClient client2 = new HttpClient();
      HttpClientConnection conn2 = client2.open('GET', "127.0.0.1", 8000, '/test');
      handleRequest(conn2, "GET", (){

        handleResponse(client2, conn2, (){

          HttpClient client3 = new HttpClient();
          HttpClientConnection conn3 = client3.open('GET', "127.0.0.1", 8000, '/test');
          handleResponse(client3, conn3, (){
            print("done!");
          });

        });

      });

    });

  });

}

handleRequest(HttpClientConnection conn, String httpMethod, Function cb){
  conn.onRequest = (HttpClientRequest httpReq) {
    print("conn.onRequest: $httpMethod");

    httpReq.headers.set(HttpHeaders.ACCEPT, "text/plain");
    if (httpMethod == "POST"){
      httpReq.headers.set(HttpHeaders.CONTENT_TYPE, "application/json");
      String jsonData = JSON.stringify({'A':1,'B':2,'C':3});
      httpReq.contentLength = jsonData.length;
      httpReq.outputStream.writeString(jsonData);
    }

    httpReq.outputStream.close();

    if (cb != null) cb();
  };
}

handleResponse(HttpClient client, HttpClientConnection conn, [Function cb]){
  StringBuffer buffer = new StringBuffer('');
  conn.onResponse = (HttpClientResponse httpRes) {
    print("conn.onResponse");

    final StringInputStream input = new StringInputStream(httpRes.inputStream);
    input.onData = () {
      print("adding data..");
      buffer.add(input.read());
    };
    input.onError = (e) => print("input.onError: $e");
    input.onClosed = (){
      print("recv: ${buffer.toString()}");
      client.shutdown();
      if (cb != null) cb();
    };
  };
  conn.onError = (e) => print("conn.onError: $e");
}
