class ParticipantCampaignContributionsByYear

  def self.for(participant)
    participant.contributions
      .posted
      .includes(:campaign)
      .order('date desc')
      .group_by {|c| c.date.year}
      .map do |year, contributions|
      [year, contributions.map(&:campaign).uniq.reject(&:nil?)]
    end
  end

end

