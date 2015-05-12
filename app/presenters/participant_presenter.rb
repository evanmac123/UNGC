class ParticipantPresenter < SimpleDelegator

  def initialize(participant, campaigns_by_year)
    super(participant)
    @campaigns_by_year = campaigns_by_year
  end

  def website
    URI::parse(website_url).hostname
  end

  def website_url
    participant.url
  end

  def has_website?
    website_url.present?
  end

  def country
    participant.country.try(:name)
  end

  def type
    participant.organization_type.name
  end

  def sector
    participant.sector.name
  end

  def ownership
    participant.listing_status.try(:name)
  end

  def joined_on
    participant.joined_on.try(:strftime, '%B, %Y')
  end

  def cops
    communication_on_progresses
  end

  def contributions
    @campaigns_by_year
  end

  private

  def participant
    __getobj__
  end

end
