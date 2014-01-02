module SignupHelper

  def signup_type
    @signup.business? ? "Business" : "Non-Business"
  end

  def pledge_radio_button(form, amount)
    form.radio_button :pledge_amount, amount, { checked: (form.object.pledge_amount == amount), class: 'fixed_pledge' }
  end
end
