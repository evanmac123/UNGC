class ParticipantPresenter < SimpleDelegator

  def initialize(participant)
    super(participant)
  end

  def participant
    __getobj__
  end

  def website
    participant.url
  end

  def website_url
    participant.url
  end

  def has_website?
    participant.url.present?
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
    participant.joined_on.strftime('%B, %Y')
  end

  def cops
    communication_on_progresses
  end

  def contributions
    participant.contributions
      .includes(:campaign)
      .order('date desc')
      .group_by {|c| c.date.year}
      .map do |year, contributions|
        campaign_names = contributions.map do |contribution|
          contribution.campaign.name
        end
        [year, campaign_names]
      end
  end

end
