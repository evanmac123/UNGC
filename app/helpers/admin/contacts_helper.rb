module Admin::ContactsHelper
  def login_fieldset_style(contact)
    if contact.can_login?
      'display: block'
    else
      'display: none'
    end
  end
  
  def login_fieldset_class(role)
    "role_for_login_fields" if Role.login_roles.include? role
  end
end
