class HeadlinePresenter < SimpleDelegator
  def tagging_presenter
    @tagging_presenter ||= TaggingPresenter.new(headline)
  end

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

  private
    def headline
      __getobj__
    end
end
