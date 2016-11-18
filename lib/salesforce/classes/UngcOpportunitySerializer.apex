public class UngcOpportunitySerializer extends UngcJsonSerializer {

  public UngcOpportunitySerializer(JSONGenerator json) {
    super(json);
  }

  public void writeUpsert(Opportunity op) {
    Account account = op.Account;

    if(account == null) {
      System.debug('Ignoring contribution without an Account');
      return;
    }

    String organizationId = op.Account.AccountNumber;
    if(organizationId == null) {
      // Account's without AccountNumber are not UNGC contributions. ignore them.
      System.debug('Ignoring non-UNGC contribution');
      return;
    }

    gen.writeStartObject();
    gen.writeStringField('type', getModelName());
    gen.writeStringField('id', op.Id);

    gen.writeStringField('organization_id', organizationId);
    gen.writeStringField('stage', op.StageName);
    gen.writeDateField('date', op.CloseDate);
    gen.writeBooleanField('is_deleted',  op.IsDeleted);

    writeNullableString('campaign_id', op.CampaignId);
    writeNullableString('invoice_code', op.Invoice_Code__c);
    writeNullableNumber('recognition_amount', op.Recognition_Amount__c);
    writeNullableNumber('raw_amount', op.Amount);
    writeNullableString('payment_type', op.Payment_type__c);
    gen.writeEndObject();
  }

  protected override String getModelName() {
    return 'contribution';
  }

}
