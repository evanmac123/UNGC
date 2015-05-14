class Redesign::Admin::Api::InitiativesController < Redesign::Admin::ApiController

  def index
    inititatives = Initiative.active.all

    render_json data: inititatives.map(&method(:serialize))
  end

  private

  def serialize(payload)
    InitiativeSerializer.new(payload).as_json
  end
end
