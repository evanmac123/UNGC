# ./script/runner 'ReverseContactRoles.new.for_organization(12345)'
# accepts the organization ID and reverses the Contact Point and CEO roles
# copies over the login information which was incorrectly assigned to the CEO

class ReverseContactRoles
  def for_organization(id)
      
      organization = Organization.find(id)
      puts "Working with #{organization.name}"
      

      if organization.contacts.ceos.count == 1 && organization.contacts.contact_points.count == 1
        puts "Reversing roles"
        
        ceo = organization.contacts.ceos.first
        contact = organization.contacts.contact_points.first
        
        # save ceo login first since we have to change it before reassigning it to the contact point
        # logins must be unique
        ceo_login = contact.login
        
        # make current ceo a contact point
        ceo.roles << Role.contact_point
        
        # logins must be unique, so change the current contact's login
        contact.login = contact.id                
        contact.save
        
        # copy original login
        ceo.login = ceo_login
        
        # copy passwords
        ceo.hashed_password = contact.hashed_password
        ceo.password = contact.password
        ceo.save
        
        # remove login/password from former contact
        contact.roles.delete(Role.contact_point)
        contact.login = nil
        contact.hashed_password = nil
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