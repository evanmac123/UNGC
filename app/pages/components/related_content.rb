class Components::RelatedContent
  def initialize(data)
    @data = data
  end

  def data
    containers.map do |c|
      {
        thumbnail: c.payload.data[:meta_tags][:thumbnail],
        issue: "no issue",
        url: c.path,
        title: c.payload.data[:meta_tags][:title]
      }
    end
  end

  private

  def containers
    blocks = @data[:related_content]
    return [] unless blocks
    paths = blocks.map {|r| r[:container_path] }
    Redesign::Container.includes(:public_payload).by_path(paths)
  end
end
