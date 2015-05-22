class Filters::EventTypeFilter < Filters::SearchFilter

  OPTIONS = [
    'online',
    'in_person',
    'invite_only'
  ]

  def initialize(types)
    super(OPTIONS, types)
    self.key = 'types'
    self.label = 'Type'
  end

  def options
    items.map do |item|
      title = I18n.t(item, scope: 'event_types')
      is_selected = selected.include?(item)
      FilterOption.new(item, title, key, is_selected, label)
    end
  end

end
