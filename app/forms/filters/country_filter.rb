class Filters::CountryFilter < Filters::FlatSearchFilter
  def initialize(selected)
    items = Country.all.select(:id, :name)
    super(items, selected)
    self.label = 'Country'
    self.key = 'countries'
  end
end
