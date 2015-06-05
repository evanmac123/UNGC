class Filters::OrganizationTypeFilter < Filters::FlatSearchFilter

  def initialize(selected)
    items = OrganizationType.all.select(:id, :name)
    super(items, selected)
    self.label = 'Type'
    self.key = 'organization_types'
  end

  protected

  def item_option(item)
    name = NAME_MAPPINGS[item.name] || item.name
    FilterOption.new(item.id, name, key, selected.include?(item.id), label)
  end

  NAME_MAPPINGS = {
    'SME' => 'Small or Medium-sized Enterprise'
  }

end
