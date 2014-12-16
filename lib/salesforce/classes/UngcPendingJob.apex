public abstract class UngcPendingJob {
  public static final Decimal OPPORTUNITY_UPSERT = 0;
  public static final Decimal OPPORTUNITY_DELETE = 1;
  public static final Decimal CAMPAIGN_UPSERT = 3;
  public static final Decimal CAMPAIGN_DELETE = 4;

  public abstract void writeTo(JSONGenerator json);
  public abstract List<UngcSync__c> serialize();
}
