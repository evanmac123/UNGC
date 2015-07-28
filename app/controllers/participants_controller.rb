class ParticipantsController < ApplicationController

  def show
    set_current_container_by_path '/what-is-gc/participants'
    contributions = ParticipantCampaignContributionsByYear.for(find_participant)
    @page = ParticipantPage.new(current_container, find_participant, contributions)
  end

  private

  def find_participant
    @participant ||= Organization.includes(
      :organization_type,
      :sector,
      :listing_status,
      :communication_on_progresses
    ).find(participant_id)
  end

  def participant_id
    params.fetch(:id).to_i
  end

end
