class Campaign < ActiveRecord::Base
  self.primary_key = :campaign_id

  has_many :contributions

  validates :campaign_id, presence: true
  validates :name, presence: true

  def private?
    self.is_private
  end
end
