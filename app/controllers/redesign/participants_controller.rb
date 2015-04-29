class Redesign::ParticipantsController < Redesign::ApplicationController

  def show
    @participant = ParticipantPresenter.new(find_participant)
  end

  private

  def find_participant
    Organization.includes(
      :organization_type,
      :sector,
      :communication_on_progresses,
      :listing_status,
      contributions: [:campaign]
    ).find(participant_id)
  end

  def participant_id
    params.fetch(:id).to_i
  end

end
