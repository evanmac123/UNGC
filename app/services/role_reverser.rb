class RoleReverser
  def self.reverse(roles)
    ceo = roles.fetch(:ceo)
    contact = roles.fetch(:contact_point)

    ceo.username = contact.username
    ceo.roles << Role.contact_point
    ceo.encrypted_password = contact.encrypted_password

    # remove login/password from former contact
    contact.roles.delete(Role.contact_point)
    contact.username = nil
    contact.encrypted_password = nil
    contact.save

    # save ceo after contact to avoid username collision
    ceo.save

    # the contact person should now be CEO
    contact.roles << Role.ceo

    # remove CEO role from contact point
    ceo.roles.delete(Role.ceo)
    true
  end
end
