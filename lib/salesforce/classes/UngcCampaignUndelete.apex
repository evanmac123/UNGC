public class UngcCampaignUndelete extends UngcJob {

  public override void saveRecord(UNGCSync__c record, Id id) {
    record.Campaign__c = id;
    record.Type__c = UngcPendingJob.CAMPAIGN_UPSERT;
  }

  public override void writeTo(JSONGenerator json) {
    UngcJsonSerializer serializer = new UngcCampaignSerializer(json);
    for(Id id : this.ids) {
      serializer.writeUndelete(id);
    }
  }
}
