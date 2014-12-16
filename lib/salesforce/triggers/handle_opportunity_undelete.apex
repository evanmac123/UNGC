trigger HandleOpportunityUndelete on Opportunity (after undelete) {
  List<Id> ids = new List<Id>();
  for(Opportunity op : Trigger.new) {
    ids.add(op.Id);
  }
  UngcSync.undeleteOpportunities(ids);
}
