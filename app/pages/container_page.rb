class ContainerPage
  attr_reader :data, :container

  def initialize(container, payload_data)
    @container = container
    @data      = payload_data || {}
  end

  def meta_title
    meta_tags.fetch(:title, '')
  end

  def meta_description
    meta_tags[:description]
  end

  def meta_keywords
    meta_tags[:keywords]
  end

  def hero
    @data[:hero] || {}
  end

  private

  def meta_tags
    @data[:meta_tags] || {}
  end
end
