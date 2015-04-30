class ParticipantCampaignContributionsByYear

  def self.for(participant)
    participant.contributions
      .includes(:campaign)
      .order('date desc')
      .group_by {|c| c.date.year}
      .map do |year, contributions|
      [year, contributions.map(&:campaign)]
    end
  end

end

