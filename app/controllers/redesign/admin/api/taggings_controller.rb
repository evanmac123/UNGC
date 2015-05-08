class Redesign::Admin::Api::TaggingsController < Redesign::Admin::ApiController

  def issues
    issues = Issue.all

    render_json data: issues.map(&method(:serialize))
  end

  def topics
    topics = Topic.all

    render_json data: topics.map(&method(:serialize))
  end

  def sectors
    sectors = Sector.all

    render_json data: sectors.map(&method(:serialize))
  end

  private

  def serialize(payload)
    TaggingSerializer.new(payload).as_json
  end
end
