public class UngcPendingJobs {
  private final List<UngcPendingJob> jobs = new List<UngcPendingJob>();

  public UngcPendingJobs() {
    jobs.add(new UngcPendingCampaignJobs());
    jobs.add(new UngcPendingOpportunityJobs());
  }

  public void writeTo(JSONGenerator json) {
    for(UngcPendingJob job : jobs) {
      job.writeTo(json);
    }
  }

  public void clear() {
    List<UngcSync__c> allSyncs = new List<UngcSync__c>();
    for(UngcPendingJob job : jobs) {
      allSyncs.addAll(job.serialize());
    }
    delete allSyncs;
  }

}
