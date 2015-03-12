class ResourcePresenter < SimpleDelegator
  def content_types_for_select
    Resource.content_types.keys.map {|k| [k.humanize.titleize, k]}
  end

  def human_content_type
    if content_type.present?
      content_type.humanize.titleize
    else
      ''
    end
  end
end
