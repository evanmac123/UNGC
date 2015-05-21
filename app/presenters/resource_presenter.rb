class ResourcePresenter < SimpleDelegator
  def tagging_presenter
    @tagging_presenter ||= TaggingPresenter.new(resource)
  end

  def content_types_for_select
    Resource.content_types.keys.map {|k| [I18n.t("resources.types.#{k}"), k]}
  end

  def human_content_type
    if content_type.present?
      I18n.t("resources.types.#{content_type}")
    else
      ''
    end
  end

  private
    def resource
      __getobj__
    end
end
