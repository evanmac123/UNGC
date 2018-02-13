class Organization::SignupForm < SimpleDelegator

  attr_accessor \
    :is_subsidiary,
    :parent_company_name,
    :primary_contact_is_financial_contact

  def model_name
    super.model_name
  end

  def organization
    __getobj__
  end
end
