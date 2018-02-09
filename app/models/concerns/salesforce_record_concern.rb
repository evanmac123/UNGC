# frozen_string_literal: true

module SalesforceRecordConcern
  extend ActiveSupport::Concern

  included do
    has_one  :salesforce_record, as: :rails
    delegate :record_id, :record_id=, to: :salesforce_record, allow_nil: true
  end

  def salesforce_id
    salesforce_record.record_id
  end

  def salesforce_record
    super || build_salesforce_record
  end

  def record_prefix
    record_id[0..2] if record_id
  end

  def record_entity
    I18n.t("salesforce.entity_prefixes.#{record_prefix}") if record_prefix
  end

  def server_id
    record_id[3..4] if record_id
  end

  def identifier
    record_id[5..17] if record_id
  end
end