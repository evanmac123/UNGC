class Components::RelatedContent
  REQUIRED_SIZE = 3

  def initialize(data)
    @data = data
  end


  def title
    related_content[:title]
  end

  def boxes
    return [] if containers.size != REQUIRED_SIZE
    containers.map { |c| Components::ContentBox.new(c) }
  end

  private

  def containers
    @container ||= begin
                     boxes = related_content[:content_boxes]
                     return [] unless boxes
                     paths = boxes.map {|r| r[:container_path] }
                     Redesign::Container.includes(:public_payload).by_path(paths)
                   end
  end

  def related_content
    @data[:related_content] || {}
  end

end
