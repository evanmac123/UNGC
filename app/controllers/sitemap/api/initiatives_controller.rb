class Sitemap::Api::InitiativesController < Sitemap::ApiController

  def index
    inititatives = Initiative.active.all

    render_json initiatives: inititatives.map(&method(:serialize))
  end

  private

  def serialize(payload)
    InitiativeSerializer.new(payload).as_json
  end
end
