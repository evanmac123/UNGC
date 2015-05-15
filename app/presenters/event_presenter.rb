class EventPresenter < SimpleDelegator
  def initialize(event)
    @event = event
    super @event
  end

  def tagging_presenter
    @tagging_presenter ||= TaggingPresenter.new(@event)
  end
end
