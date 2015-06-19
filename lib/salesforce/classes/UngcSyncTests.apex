@isTest
private class UngcSyncTests {

  private class MockResponse implements HttpCalloutMock {
    private final Integer code;

    public MockResponse(Integer statusCode) {
      this.code = statusCode;
    }

    public HTTPResponse respond(HTTPRequest req) {
      System.assertEquals('https://www.unglobalcompact.org/salesforce/sync', req.getEndpoint());
      System.assertEquals('POST', req.getMethod());

      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{}');
      res.setStatusCode(code);
      return res;
    }
  }

  static testMethod void testHappyPath() {
    Test.setMock(HttpCalloutMock.class, new MockResponse(200));

    Campaign campaign = createCampaign();
    Opportunity opportunity = createOpportunity();

    insert campaign;
    insert opportunity;

    update campaign;
    update opportunity;

    delete campaign;
    delete opportunity;

    undelete campaign;
    undelete opportunity;
  }

  static testMethod void testFailurePath() {
    Test.setMock(HttpCalloutMock.class, new MockResponse(422));

    Campaign campaign = createCampaign();
    Opportunity opportunity = createOpportunity();

    insert campaign;
    insert opportunity;

    update campaign;
    update opportunity;

    delete campaign;
    delete opportunity;

    undelete campaign;
    undelete opportunity;
  }

  private static Opportunity createOpportunity() {
    Account account = new Account(name='Test Accoount', AccountNumber='1234');
    insert account;

    Opportunity opportunity = new Opportunity(
      Name='Test Opportunity',
      StageName = 'Posted',
      CloseDate = Date.newInstance(2020, 1, 1),
      AccountId = account.Id,
      Account = account
    );

    return opportunity;
  }

  private static Campaign createCampaign() {
    return new Campaign(
      name='Test Campaign',
      IsPrivate = true
    );
  }

}
