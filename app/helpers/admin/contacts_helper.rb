module Admin::ContactsHelper
  def login_fieldset_style(contact)
    # TODO network report contact also needs the login fields
    if contact.is? Role.contact_point
      'display: block'
    else
      'display: none'
    end
  end
end