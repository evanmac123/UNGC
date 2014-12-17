public class UngcOpportunityUndelete extends UngcJob {

  public override void saveRecord(UNGCSync__c record, Id id) {
    record.Opportunity__c = id;
    record.Type__c = UngcPendingJob.OPPORTUNITY_UPSERT;
  }

  public override void writeTo(JSONGenerator json) {
    UngcJsonSerializer serializer = new UngcOpportunitySerializer(json);
    for(Id id : this.ids) {
      serializer.writeUndelete(id);
    }
  }
}
