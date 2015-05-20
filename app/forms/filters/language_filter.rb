class Filters::LanguageFilter < Filters::FlatSearchFilter

  def initialize(selected)
    items = Language.all.select(:id, :name)
    super(items, selected)
    self.label = 'Language'
    self.key = 'languages'
  end

end
