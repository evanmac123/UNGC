class EventPresenter < SimpleDelegator
  def tagging_presenter
    @tagging_presenter ||= TaggingPresenter.new(event)
  end

  private
    def event
      __getobj__
    end
end
