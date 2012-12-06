# ./script/runner 'ReverseContactRoles.new.for_organization(12345)'
# accepts the organization ID and reverses the Contact Point and CEO roles
# copies over the username information which was incorrectly assigned to the CEO

class ReverseContactRoles
  def for_organization(id)

      organization = Organization.find(id)
      puts "Working with #{organization.name}"


      if organization.contacts.ceos.count == 1 && organization.contacts.contact_points.count == 1
        # self.errors.add :base,("Sorry, the roles could not be reversed because there is more than one contact point or CEO")
        puts "Reversing roles"

        ceo = organization.contacts.ceos.first
        contact = organization.contacts.contact_points.first

        # save ceo username first since we have to change it before reassigning it to the contact point
        # usernames must be unique
        ceo_username = contact.username

        # make current ceo a contact point
        ceo.roles << Role.contact_point

        # usernames must be unique, so change the current contact's username
        contact.username = contact.id
        contact.save

        # copy original username
        ceo.username = ceo_username

        # copy passwords
        ceo.encrypted_password = contact.encrypted_password
        ceo.password = contact.password
        ceo.save

        # remove username/password from former contact
        contact.roles.delete(Role.contact_point)
        contact.username = nil
        contact.encrypted_password = nil
        contact.password = nil
        contact.save

        # the contact person should now be CEO
        contact.roles << Role.ceo

        # remove CEO role from contact point
        ceo.roles.delete(Role.ceo)

      else
        puts "Sorry, the roles could not be reversed because there is more than one contact point or CEO"
      end

  end

end
