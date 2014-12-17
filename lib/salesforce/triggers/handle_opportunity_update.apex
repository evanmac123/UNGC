trigger HandleOpportunityUpdate on Opportunity (after update) {
  List<Id> ids = new List<Id>();
  for(Opportunity op : Trigger.new) {
    ids.add(op.Id);
  }
  UngcSync.upsertOpportunities(ids);
}
