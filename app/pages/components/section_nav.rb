# TODO optimize to avoid N+1 queries

class Components::SectionNavLink

  def initialize(container, current_container = nil)
    @container = container
    @current_container = current_container
  end

  def title
    container.payload.data[:meta_tags][:title] rescue nil
  end

  def path
    container.path
  end

  def is_current
    current_container == container
  end

  private

  attr_reader :container, :current_container
end

class Components::SectionNav

  def initialize(container)
    @container = container
  end

  def current
    Components::SectionNavLink.new(container)
  end

  def siblings
    return [] unless container.parent_container
    container.parent_container.child_containers.visible.includes(:public_payload).map do |c|
      Components::SectionNavLink.new(c, container)
    end
  end

  def parent
    Components::SectionNavLink.new(container.parent_container) if container.parent_container && container.parent_container.visible
  end

  def children
    container.child_containers.visible.includes(:public_payload).map do |c|
      Components::SectionNavLink.new(c)
    end
  end

  private

  attr_reader :container
end
