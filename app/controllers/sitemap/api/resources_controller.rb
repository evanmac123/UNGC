class Sitemap::Api::ResourcesController < Sitemap::ApiController

  def index
    contacts  = Resource.all

    render_json resources: contacts.map(&method(:serialize))
  end

  private

  def serialize(payload)
    ResourceSerializer.new(payload).as_json
  end
end

