class Campaign < ActiveRecord::Base
  self.primary_key = :campaign_id

  has_many :contributions

  validates :campaign_id, presence: true
  validates :name, presence: true

  scope :for_public, -> { where(is_private: false) }

  def private?
    self.is_private
  end

  def public?
    !private?
  end

end
