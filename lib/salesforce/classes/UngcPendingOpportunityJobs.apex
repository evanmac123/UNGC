public class UngcPendingOpportunityJobs extends UngcPendingJob {
  private List<UngcSync__c> syncs;

  public override void writeTo(JSONGenerator json) {
    UngcOpportunitySerializer serializer = new UngcOpportunitySerializer(json);
    for(UNGCSync__c job : serialize()) {
      if(job.Type__c == OPPORTUNITY_UPSERT) {
        serializer.writeUpsert(job.Opportunity__r);
      } else if(job.Type__c == OPPORTUNITY_DELETE) {
        serializer.writeDelete(job.DeletedId__c);
      }
    }
  }

  public override List<UngcSync__c> serialize() {
    if(this.syncs == null) {
      this.syncs = [
        SELECT  Opportunity__c,
                Type__c,
                DeletedId__c,
                Opportunity__r.Account.AccountNumber,
                Opportunity__r.CampaignId,
                Opportunity__r.Invoice_Code__c,
                Opportunity__r.Recognition_Amount__c,
                Opportunity__r.Amount,
                Opportunity__r.StageName,
                Opportunity__r.CloseDate,
                Opportunity__r.Payment_type__c,
                Opportunity__r.IsDeleted
        FROM    UNGCSync__c
        WHERE   Type__c = :OPPORTUNITY_UPSERT
        OR      Type__c = :OPPORTUNITY_DELETE
      ];
    }
    return this.syncs;
  }
}
