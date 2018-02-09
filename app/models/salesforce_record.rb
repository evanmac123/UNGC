# frozen_string_literal: true

class SalesforceRecord < ActiveRecord::Base
  validates :record_id, length: { minimum: 15, maximum: 18 }, presence: true, uniqueness: true

  belongs_to :rails, polymorphic: true

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
