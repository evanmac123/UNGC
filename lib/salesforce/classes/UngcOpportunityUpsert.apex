public class UngcOpportunityUpsert extends UngcJob {

  public override void saveRecord(UNGCSync__c record, Id id) {
    record.Opportunity__c = id;
    record.Type__c = UngcPendingJob.OPPORTUNITY_UPSERT;
  }

  public override void writeTo(JSONGenerator json) {
    UngcOpportunitySerializer serializer = new UngcOpportunitySerializer(json);
    for(Opportunity o : load()) {
      serializer.writeUpsert(o);
    }
  }

  private List<Opportunity> load() {
    return [
      SELECT  Id,
              Account.AccountNumber,
              CampaignId,
              Invoice_Code__c,
              Recognition_Amount__c,
              Amount,
              StageName,
              CloseDate,
              Payment_type__c,
              IsDeleted
      FROM    Opportunity
      WHERE   Id in :ids
    ];
  }
}
