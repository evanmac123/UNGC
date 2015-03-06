class SearchForm
  include ActiveModel::Model
  # TODO find a better way to convert values. virtus?
  # TODO handle grouped drop downs (eg: sector)

  attr_accessor \
    :author,
    :issue,
    :topic,
    :language,
    :sector,
    :type

  def issue_options
    Issue.all.map {|i| [i.name, i.id]}
  end

  def topic_options
    Topic.all.map {|i| [i.name, i.id]}
  end

  def language_options
    Language.all.map {|i| [i.name, i.id]}
  end

  def sector_options
    Sector.all.map {|i| [i.name, i.id]}
  end

  def type_options
    Resource.content_types.to_a.map do |name, id|
      title = I18n.t("resources.types.#{name}")
      [title, id]
    end
  end

  def issue=(value)
    @issue = if value.present? then value.to_i end
  end

  def topic=(value)
    @topic = if value.present? then value.to_i end
  end

  def language=(value)
    @language = if value.present? then value.to_i end
  end

  def sector=(value)
    @sector = if value.present? then value.to_i end
  end

  def type=(value)
    @type = if value.present? then value.to_i end
  end

end
