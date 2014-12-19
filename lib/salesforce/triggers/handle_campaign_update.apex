trigger HandleCampaignUpdate on Campaign (after update) {
  List<Id> ids = new List<Id>();
  for(Campaign op : Trigger.new) {
    ids.add(op.Id);
  }
  UngcSync.upsertCampaigns(ids);
}
