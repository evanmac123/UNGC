class Filters::OrganizationTypeFilter < Filters::FlatSearchFilter

  def initialize(selected)
    items = OrganizationType.all.select(:id, :name)
    super(items, selected)
    self.label = 'Type'
    self.key = 'organization_types'
  end

end
