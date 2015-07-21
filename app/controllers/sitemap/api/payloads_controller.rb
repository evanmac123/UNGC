class Sitemap::Api::PayloadsController < Sitemap::ApiController
  def index
    container = Redesign::Container.find(params[:container])
    payloads  = container.payloads.order(created_at: :desc).limit(10).load

    render_json data: payloads.map(&method(:serialize))
  end

  def show
    render_json data: serialize(Payload.find(params[:id]))
  end

  private

  def serialize(payload)
    PayloadSerializer.new(payload).as_json
  end
end
