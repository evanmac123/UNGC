class EventPresenter < SimpleDelegator
  delegate(:topic_options, :issue_options, :sector_options, to: :tagging_presenter)

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

  def sponsor_options
    Sponsor.order(:name).map { |s| [s.name, s.id] }
  end

  def sponsor_options
    Sponsor.order(:name).map do |sponsor|
      add_selections(sponsor, :sponsor, selected_sponsors)
    end
  end

  private
    def event
      __getobj__
    end

    def selected_sponsors
      event.sponsor_ids
    end

    def add_selections(sponsor, type, selected_ids)
      sponsor_option = FilterOption.new(sponsor.id, sponsor.name, type, selected_ids.include?(sponsor.id))

      sponsor_option
    end

    def tagging_presenter
      @tagging_presenter ||= TaggingPresenter.new(event)
    end
end
