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

  def kind
    case
    when lead?
      'lead'
    when annual?
      'annual'
    else
      'unknown'
    end
  end

  def lead?
    name =~ ContributionStatus::YEAR_LEAD_REGEXP
  end

  def annual?
    name =~ ContributionStatus::YEAR_CAMPAIGN_REGEXP
  end

end
