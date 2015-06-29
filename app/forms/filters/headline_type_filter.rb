class Filters::HeadlineTypeFilter < Filters::SearchFilter

  def initialize(types)
    super(Headline.headline_types, types)
    self.key = 'types'
    self.label = 'Type'
  end

  def options
    items.map do |type|
      k, value = type
      title = I18n.t(k, scope: :headline)
      is_selected = selected.include?(value)
      FilterOption.new(value, title, key, is_selected, label)
    end
  end

end
