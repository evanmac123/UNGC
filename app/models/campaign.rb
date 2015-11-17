class Campaign < ActiveRecord::Base
  YEAR_CAMPAIGN_REGEXP = /\A(?<year>\d\d\d\d) Annual Contributions\z/
  YEAR_LEAD_REGEXP = /\ALEAD (?<year>\d\d\d\d).*\z/

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
    name =~ YEAR_LEAD_REGEXP
  end

  def annual?
    name =~ YEAR_CAMPAIGN_REGEXP
  end

  def year
    name.match(campaign_regexp).try(:[], :year).try(:to_i)
  end

  private

  def campaign_regexp
    Regexp.new(YEAR_LEAD_REGEXP.source + "|" +  YEAR_CAMPAIGN_REGEXP.source)
  end

end
