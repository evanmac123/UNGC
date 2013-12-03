class BusinessOrganizationRegistration
  include Virtus.model

  attribute :date, DateTime
  attribute :place, String
  attribute :authority, String
  attribute :number, String
  attribute :mission_statement, String

  def self.model_name
    NonBusinessOrganizationRegistration.model_name
  end

  def update_attributes(params)
    true
  end

  def error_message
    ""
  end
end

