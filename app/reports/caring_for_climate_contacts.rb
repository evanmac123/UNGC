class CaringForClimateContacts < InitiativesContactsBase

  def initialize
    super(initiative_name: Initiative::FILTER_TYPES[:climate], role_id: Role.caring_for_climate.id,
          signed_on_header: 'signed_c4c_on')
  end

end
