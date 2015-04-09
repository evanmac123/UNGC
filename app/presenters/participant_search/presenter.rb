class ParticipantSearch::Presenter < SimpleDelegator

  def initialize(search = nil)
    super(search || ParticipantSearch::Form.new)
  end

  def organization_type_options
    OrganizationType.pluck(:name, :id)
  end

  def initiative_options
    Initiative.pluck(:name, :id)
  end

  def geography_options
    Country.pluck(:name, :id)
  end

end
