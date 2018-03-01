class ParticipantCampaignContributionsByYear

  class << self
    def for(participant)
      participant.contributions
        .posted
        .includes(:campaign)
        .references(:campaign)
        .merge(Campaign.for_public)
        .order('date desc')
        .group_by {|c| c.date.year}
        .map do |year, contributions|
          [year, public_campaigns(contributions)]
        end
    end

    private

    def public_campaigns(contributions)
      contributions
        .map(&:campaign)
        .select { |campaign| campaign.present? && campaign.public? }
        .uniq
    end

  end

end
