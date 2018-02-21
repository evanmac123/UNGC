# frozen_string_literal: true
# == Schema Information
#
# Table name: salesforce_records
#
#  id         :integer          not null, primary key
#  record_id  :string(18)       not null
#  rails_id   :integer
#  rails_type :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#


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
