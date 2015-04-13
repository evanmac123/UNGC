# TODO optimize to avoid N+1 queries

class Components::SectionNavLink

  def initialize(container)
    @container = container
  end

  def title
    container.payload.data[:meta_tags][:title] rescue nil
  end

  def url
    container.path
  end

  private

  attr_reader :container
end

class Components::SectionNav

  def initialize(container)
    @container = container
  end

  def current
    Components::SectionNavLink.new(container)
  end

  def parent
    Components::SectionNavLink.new(container.parent_container)
  end

  def children
    container.child_containers.includes(:public_payload).map do |c|
      Components::SectionNavLink.new(c)
    end
  end

  private

  attr_reader :container
end
