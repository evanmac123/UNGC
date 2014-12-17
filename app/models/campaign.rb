class Campaign < ActiveRecord::Base
  set_primary_key :campaign_id
  has_many :contributions

  validate :campaign_id, presence: true
  validate :name, presence: true
end
