public abstract class UngcJob {

  protected List<Id> ids = new List<Id>();

  public abstract void writeTo(JSONGenerator json);

  protected abstract void saveRecord(UNGCSync__c record, Id id);

  public void add(List<Id> ids) {
    this.ids = ids;
  }

  public void save(List<String> errors) {
    List<UNGCSync__c> syncs = new List<UNGCSync__c>();
    for(Id id : this.ids) {
      UNGCSync__c record = new UNGCSync__c();
      record.Errors__c = String.join(errors, ' ::: ');
      saveRecord(record, id);
      syncs.add(record);
    }
    insert syncs;
  }

}
