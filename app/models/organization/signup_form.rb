class Organization::SignupForm < SimpleDelegator

  attr_accessor \
    :is_subsidiary,
    :parent_company_name

  def model_name
    super.model_name
  end

end
