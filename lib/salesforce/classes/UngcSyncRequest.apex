public class UngcSyncRequest {
  private static final String UNGC_URL = 'https://www.unglobalcompact.org/salesforce/sync';
  private static final String API_TOKEN = '16d7d6089b8fe0c5e19bfe10bb156832';

  private final List<String> errors;
  private final String body;

  public static boolean httpCallsAreMocked = false;

  public UngcSyncRequest(String body) {
    this.body = body;
    this.errors = new List<String>();
  }

  public boolean send() {
    HttpRequest req = createRequest();
    HTTPResponse res = sendRequest(req);
    if (res.getStatusCode() == 200) {
      return true;
    } else {
      String message = 'Error from ' + req.getEndpoint() + ': (' + res.getStatusCode() + ') ' + res.getStatus();
      errors.add(message);
      errors.add('service returned:' + res.getBody());
      return false;
    }
  }

  public List<String> getErrors() {
    return errors;
  }

  private HTTPResponse sendRequest(HttpRequest request) {
    Http http = new Http();
    if(!Test.isRunningTest() || UngcSyncRequest.httpCallsAreMocked) {
      System.debug('using real http calls');
      return http.send(request);
    } else {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{}');
      res.setStatusCode(200);
      return res;
    }
  }

  private HttpRequest createRequest() {
    HttpRequest req = new HttpRequest();
    req.setMethod('POST');
    req.setEndpoint(UNGC_URL);
    req.setHeader('Content-Type', 'application/json');
    req.setHeader('Authorization', 'Token token=' + API_TOKEN);
    req.setBody(this.body);
    return req;
  }
}
