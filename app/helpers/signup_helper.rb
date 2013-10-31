module SignupHelper

  def signup_type
    @signup.business? ? "Business" : "Non-Business"
  end

end
