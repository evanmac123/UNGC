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
  # TODO refactor logic that determines if we can display a container
  # currenlty we have to check if the container is visible: true
  # and if the container has a published payload
  # we are using the published scope but also check for public_payload_id
  # when we look at the parent

  def initialize(container)
    @container = container
  end

  def current
    Components::SectionNavLink.new(container)
  end

  def siblings
    return [] unless container.parent_container
    container.parent_container.child_containers.visible.published.includes(:public_payload).map do |c|
      Components::SectionNavLink.new(c, container)
    end
  end

  def parent
    Components::SectionNavLink.new(container.parent_container) if container.parent_container && container.parent_container.visible && container.parent_container.public_payload_id
  end

  def children
    container.child_containers.visible.published.includes(:public_payload).map do |c|
      Components::SectionNavLink.new(c)
    end
  end

  private

  attr_reader :container
end
