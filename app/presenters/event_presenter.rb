class EventPresenter < SimpleDelegator
  def tagging_presenter
    @tagging_presenter ||= TaggingPresenter.new(event)
  end

  def priority_options
    Event.priorities.keys.map do |value|
      title = value.scan(/\d+|[a-z]+/i).join(' ').titleize
      [title,value]
    end
  end

  def country_options
    Country.order(:name).map { |c| [c.name, c.id] }
  end

  def contact_options
    Contact.joins(:organization).where('organizations.name = ?', DEFAULTS[:ungc_organization_name]).map do |c|
      [c.name, c.id]
    end
  end

  private
    def event
      __getobj__
    end
end
