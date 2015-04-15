class Components::RelatedContent
  REQUIRED_SIZE = 3

  def initialize(data)
    @data = data
  end

  def data
    return [] if containers.size != REQUIRED_SIZE
    containers.map { |c| Components::ContentBox.new(c) }
  end

  private

  def containers
    blocks = @data[:related_content]
    return [] unless blocks
    paths = blocks.map {|r| r[:container_path] }
    Redesign::Container.includes(:public_payload).by_path(paths)
  end
end
