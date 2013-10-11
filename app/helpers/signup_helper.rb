module SignupHelper

  def signup_type
    @os.business? ? "Business" : "Non-Business"
  end

end
