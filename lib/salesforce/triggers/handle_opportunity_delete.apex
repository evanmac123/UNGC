trigger HandleOpportunityDelete on Opportunity (after delete) {
  List<Id> ids = new List<Id>();
  for(Opportunity op : Trigger.old) {
    ids.add(op.Id);
  }
  UngcSync.deleteOpportunities(ids);
}
