require 'components/contact_component'
require 'components/resource_component'
require 'components/events_component'

class ArticlePage
  def initialize(container, payload_data)
    @container = container
    @data      = payload_data || {}
  end

  def hero
    @data[:hero] || {}
  end

  def article_block
    article_block = @data[:article_block] || {}
    article_block[:widgets] = widgets
    article_block
  end

  def widgets
    widgets = {}

    widgets[:contact] = ContactComponent.new(@data).data

    widgets[:call_to_action] = @data[:widget_call_to_action] if @data[:widget_call_to_action]

    widgets[:links_list] = @data[:widget_links_list] if @data[:widget_links_list]

    widgets
  end


  def resources
    ResourceComponent.new(@data).data
  end

  def events
    EventsComponent.new(@data).data
  end
end

