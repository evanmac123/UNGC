class Redesign::Admin::Api::ResourcesController < Redesign::Admin::ApiController

  def index
    contacts  = Resource.all

    render_json data: contacts.map(&method(:serialize))
  end

  private

  def serialize(payload)
    ResourceSerializer.new(payload).as_json
  end
end

