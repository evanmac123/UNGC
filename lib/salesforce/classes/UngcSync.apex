public class UngcSync {

  @future(callout=true)
  public static void deleteCampaigns(List<Id> ids) {
    UngcJob job = new UngcCampaignDelete();
    job.add(ids);
    run(job);
  }

  @future(callout=true)
  public static void upsertCampaigns(List<Id> ids) {
    UngcJob job = new UngcCampaignUpsert();
    job.add(ids);
    run(job);
  }

  @future(callout=true)
  public static void undeleteCampaigns(List<Id> ids) {
    UngcJob job = new UngcCampaignUndelete();
    job.add(ids);
    run(job);
  }

  @future(callout=true)
  public static void deleteOpportunities(List<Id> ids) {
    UngcJob job = new UngcOpportunityDelete();
    job.add(ids);
    run(job);
  }

  @future(callout=true)
  public static void upsertOpportunities(List<Id> ids) {
    UngcJob job = new UngcOpportunityUpsert();
    job.add(ids);
    run(job);
  }

  @future(callout=true)
  public static void undeleteOpportunities(List<Id> ids) {
    UngcJob job = new UngcOpportunityUndelete();
    job.add(ids);
    run(job);
  }

  private static void run(UngcJob job) {
    UngcPendingJobs pendingJobs = new UngcPendingJobs();

    JSONGenerator gen = JSON.createGenerator(true);
    gen.writeStartArray();
    pendingJobs.writeTo(gen);
    job.writeTo(gen);
    gen.writeEndArray();

    UngcSyncRequest request = new UngcSyncRequest(gen.getAsString());
    if(request.send()) {
      pendingJobs.clear();
    } else {
      job.save(request.getErrors());
    }
  }
}
