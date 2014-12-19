class Campaign < ActiveRecord::Base
  self.primary_key = :campaign_id

  has_many :contributions

  validate :campaign_id, presence: true
  validate :name, presence: true
end
