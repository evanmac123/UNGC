class Sitemap::Api::TaggingsController < Sitemap::ApiController

  def issues
    issues = Issue.all

    render_json issues: issues.map(&method(:serialize))
  end

  def topics
    topics = Topic.all

    render_json topics: topics.map(&method(:serialize))
  end

  def sectors
    sectors = Sector.all

    render_json sectors: sectors.map(&method(:serialize))
  end

  private

  def serialize(payload)
    TaggingSerializer.new(payload).as_json
  end
end
