class ParticipantsController < ApplicationController

  def show
    set_current_container_by_path '/what-is-gc/participants'
    @participant = find_participant
    contributions = ParticipantCampaignContributionsByYear.for(@participant)
    @page = ParticipantPage.new(current_container, @participant, contributions)
  end

  private

  def find_participant
    Organization.includes(
      :organization_type,
      :sector,
      :listing_status,
      :communication_on_progresses,
      action_platform_subscriptions: [:platform]
    ).participants.find(participant_id)
  end

  def participant_id
    params.fetch(:id).to_i # remove slug
  end

end
