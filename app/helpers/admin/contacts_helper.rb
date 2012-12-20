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

  def current_user_can_delete(current_user, tabbed_contact)
    return false if current_user == tabbed_contact

    return true if current_user.from_ungc? || current_user.from_network?

    if current_user.from_organization?
      return current_user.organization.participant ? true : false
    end
  end

end