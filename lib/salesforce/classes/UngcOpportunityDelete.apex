public class UngcOpportunityDelete extends UngcJob {

  public override void saveRecord(UNGCSync__c record, Id id) {
    record.DeletedId__c = id;
    record.Type__c = UngcPendingJob.OPPORTUNITY_DELETE;
  }

  public override void writeTo(JSONGenerator json) {
    UngcJsonSerializer serializer = new UngcOpportunitySerializer(json);
    for(Id id : this.ids) {
      serializer.writeDelete(id);
    }
  }
}
