class Filters::InitiativeFilter < Filters::FlatSearchFilter

  def initialize(selected)
    items = Initiative.active.select(:id, :name)
    super(items, selected)
    self.label = 'Initiative'
    self.key = 'initiatives'
  end

end
