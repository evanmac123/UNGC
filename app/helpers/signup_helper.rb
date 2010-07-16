module SignupHelper

  def signup_type
    @organization.business_entity? ? "Business" : "Non-Business"
  end

end
