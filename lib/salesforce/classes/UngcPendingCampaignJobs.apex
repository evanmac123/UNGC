public class UngcPendingCampaignJobs extends UngcPendingJob {
  private List<UngcSync__c> syncs;

  public override void writeTo(JSONGenerator json) {
    UngcCampaignSerializer serializer = new UngcCampaignSerializer(json);
    for(UNGCSync__c job : serialize()) {
      if(job.Type__c == CAMPAIGN_UPSERT) {
        serializer.writeUpsert(job.Campaign__r);
      } else if(job.Type__c == CAMPAIGN_DELETE) {
        serializer.writeDelete(job.DeletedId__c);
      }
    }
  }

  public override List<UngcSync__c> serialize() {
    if(this.syncs == null) {
      this.syncs = [
        SELECT  Campaign__c,
                Type__c,
                Campaign__r.Name,
                Campaign__r.StartDate,
                Campaign__r.EndDate,
                Campaign__r.IsDeleted,
                DeletedId__c
        FROM    UNGCSync__c
        WHERE   Type__c = :CAMPAIGN_UPSERT
        OR      Type__c = :CAMPAIGN_DELETE
      ];
    }
    return this.syncs;
  }
}