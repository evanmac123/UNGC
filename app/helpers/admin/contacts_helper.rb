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

  def current_contact_can_delete(current_contact, tabbed_contact)
    return false if current_contact == tabbed_contact

    return true if current_contact.from_ungc? || current_contact.from_network?

    if current_contact.from_organization?
      return current_contact.organization.participant ? true : false
    end
  end

end