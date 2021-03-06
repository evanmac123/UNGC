class HeadlinePresenter < SimpleDelegator

  delegate  \
    :topic_options,
    :issue_options,
    :sector_options,
    :sustainable_development_goal_options,
    to: :tagging_presenter

  def headline_types_for_select
    Headline.headline_types.keys.map {|k| [k.humanize.titleize, k]}
  end

  def human_headline_type
    if headline_type.present?
      headline_type.humanize.titleize
    else
      ''
    end
  end

  def contact_options
    Contact.ungc_staff.map do |c|
      [c.name, c.id]
    end
  end

  private
    def headline
      __getobj__
    end

    def tagging_presenter
      @tagging_presenter ||= TaggingPresenter.new(headline)
    end
end
