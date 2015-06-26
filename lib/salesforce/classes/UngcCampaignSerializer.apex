public class UngcCampaignSerializer extends UngcJsonSerializer {

  public UngcCampaignSerializer(JSONGenerator json) {
    super(json);
  }

  public void writeUpsert(Campaign c) {
    gen.writeStartObject();
    gen.writeStringField('type', getModelName());
    gen.writeStringField('id', c.Id);
    gen.writeStringField('name', c.Name);
    writeNullableDate('start_date', c.StartDate);
    writeNullableDate('end_date', c.EndDate);
    gen.writeBooleanField('is_deleted',  c.IsDeleted);
    gen.writeBooleanField('is_private', c.IsPrivate__c);
    gen.writeEndObject();
  }

  protected override String getModelName() {
    return 'campaign';
  }

}
