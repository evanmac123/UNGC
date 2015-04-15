class Components::RelatedContent
  def initialize(data)
    @data = data
  end

  def data
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
