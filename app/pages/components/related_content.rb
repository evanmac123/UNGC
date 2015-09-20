class Components::RelatedContent
  REQUIRED_SIZE = 3

  def initialize(data)
    @data = data
    @content_boxes = related_content[:content_boxes]
    @paths = @content_boxes.map {|r| r[:container_path] }
  end

  def title
    related_content[:title]
  end

  def boxes
    return [] if containers.size != REQUIRED_SIZE
    containers
  end

  private

  def containers
    @container ||= begin
                     return [] unless @content_boxes
                     fetch_boxes
                   end
  end

  def related_content
    @data
  end

  def fetch_boxes
    # we want to keep the order while avoiding extra queries
    cs = fetch_containers
    es = fetch_events

    @paths.map do |path|
      container_box = cs.find {|c| c.url == path}
      event_box = es.find {|e| e.url == path }
      container_box || event_box
    end.compact
  end

  def events_path
    @events_path ||= Regexp.new(Rails.application.routes.url_helpers.events_path + "/")
  end

  # returns ids for events and paths for containers
  def normalized_paths
    @paths.map do |path|
      if path =~ events_path
        path.gsub(events_path, '').to_i
      else
        path
      end
    end
  end

  def fetch_containers
    cpaths = normalized_paths.select { |p| p.is_a? String }
    Container.includes(:public_payload).by_path(cpaths).map do |c|
      Components::ContentBox.new(c)
    end
  end

  def fetch_events
    epaths = normalized_paths.select { |p| p.is_a? Integer }
    Event.where('id in (?)', epaths).map do |e|
      Components::EventBox.new(e)
    end
  end

end
