trigger HandleCampaignDelete on Campaign (after delete) {
  List<Id> ids = new List<Id>();
  for(Campaign op : Trigger.old) {
    ids.add(op.Id);
  }
  UngcSync.deleteCampaigns(ids);
}
