class Redesign::ParticipantsController < Redesign::ApplicationController

  def show
    contributions = ParticipantCampaignContributionsByYear.for(find_participant)
    @page = ParticipantPage.new(find_participant, contributions)
  end

  private

  def find_participant
    @participant ||= Organization.includes(
      :organization_type,
      :sector,
      :listing_status,
      :communication_on_progresses,
      :contributions
    ).find(participant_id)
  end

  def participant_id
    params.fetch(:id).to_i
  end

end
