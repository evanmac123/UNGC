class Redesign::Admin::Api::TaggingsController < Redesign::Admin::ApiController

  def issues
    issues = Issue.children.pluck(:id, :name)

    render_json data: issues.map(&method(:serialize))
  end

  def topics
    topics = Topic.children.pluck(:id, :name)

    render_json data: topics.map(&method(:serialize))
  end

  def sectors
    sectors = Sector.children.pluck(:id, :name)

    render_json data: sectors.map(&method(:serialize))
  end

  private

  def serialize(payload)
    TaggingSerializer.new(payload).as_json
  end
end
