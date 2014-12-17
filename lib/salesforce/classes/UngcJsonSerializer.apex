public abstract class UngcJsonSerializer {
  protected final JSONGenerator gen;

  public UngcJsonSerializer(JSONGenerator json) {
    gen = json;
  }

  protected abstract String getModelName();

  public void writeDelete(Id id) {
    writeDeleteOrUndelete(id, true);
  }

  public void writeUndelete(Id id) {
    writeDeleteOrUndelete(id, false);
  }

  private void writeDeleteOrUndelete(Id id, boolean isDeleted) {
    gen.writeStartObject();
    gen.writeStringField('type', getModelName());
    gen.writeStringField('id', id);
    gen.writeBooleanField('is_deleted', isDeleted);
    gen.writeEndObject();
  }

  protected void writeNullableString(String field, String value) {
    if(value == null) {
      gen.writeNullField(field);
    } else {
      gen.writeStringField(field, value);
    }
  }

  protected void writeNullableNumber(String field, Decimal value) {
    if(value == null) {
      gen.writeNullField(field);
    } else {
      gen.writeNumberField(field, value);
    }
  }

  protected void writeNullableDate(String field, Date value) {
    if(value == null) {
      gen.writeNullField(field);
    } else {
      gen.writeDateField(field, value);
    }
  }
}
