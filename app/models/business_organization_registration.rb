class BusinessOrganizationRegistration < OpenStruct

  def self.model_name
    NonBusinessOrganizationRegistration.model_name
  end

  def update_attributes(params)
    true
  end

  def error_message
    ""
  end

  def to_model
  end
end

