# takes a container and exposes the right data
# for content boxes to display

class Components::ContentBox
  attr_reader :container

  def initialize(container)
    @container = container
  end

  def thumbnail
    return unless payload?
    container.payload.data[:meta_tags][:thumbnail]
  end

  def issue
    "no issue" # TODO implement this
  end

  def url
    container.path
  end

  def title
    return unless payload?
    container.payload.data[:meta_tags][:title]
  end

  private

  def payload?
    container.payload.present?
  end

end
