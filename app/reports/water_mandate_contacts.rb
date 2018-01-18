class WaterMandateContacts < InitiativesContactsBase

  def initialize(options = {})
    super(initiative_name: Initiative::FILTER_TYPES[:water_mandate], role_id: Role.ceo_water_mandate.id,
          signed_on_header: 'signed_mandate_on')
  end

end
