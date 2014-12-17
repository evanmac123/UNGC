public class UngcCampaignDelete extends UngcJob {

  public override void saveRecord(UNGCSync__c record, Id id) {
    record.DeletedId__c = id;
    record.Type__c = UngcPendingJob.CAMPAIGN_DELETE;
  }

  public override void writeTo(JSONGenerator json) {
    UngcJsonSerializer serializer = new UngcCampaignSerializer(json);
    for(Id id : this.ids) {
      serializer.writeDelete(id);
    }
  }
}
