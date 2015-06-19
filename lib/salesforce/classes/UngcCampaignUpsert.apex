public class UngcCampaignUpsert extends UngcJob {

  public override void saveRecord(UNGCSync__c record, Id id) {
    record.Campaign__c = id;
    record.Type__c = UngcPendingJob.CAMPAIGN_UPSERT;
  }

  private List<Campaign> load() {
    return [
      SELECT  Id,
              Name,
              StartDate,
              EndDate,
              IsDeleted,
              IsPrivate
      FROM    Campaign
      WHERE   Id in :ids
    ];
  }

  public override void writeTo(JSONGenerator json) {
    UngcCampaignSerializer serializer = new UngcCampaignSerializer(json);
    for(Campaign c : load()) {
      serializer.writeUpsert(c);
    }
  }
}
