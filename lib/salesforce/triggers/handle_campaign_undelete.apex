trigger HandleCampaignUndelete on Campaign (after undelete) {
  List<Id> ids = new List<Id>();
  for(Campaign op : Trigger.new) {
    ids.add(op.Id);
  }
  UngcSync.undeleteCampaigns(ids);
}
