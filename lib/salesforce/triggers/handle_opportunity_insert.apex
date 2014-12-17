trigger HandleOpportunityInsert on Opportunity (after insert) {
  List<Id> ids = new List<Id>();
  for(Opportunity op : Trigger.new) {
    ids.add(op.Id);
  }
  UngcSync.upsertOpportunities(ids);
}
