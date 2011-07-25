class RemoveGcNetworksOrganizations < ActiveRecord::Migration
  # local versions of the model classes, to avoid trampling by newer code
  # see: http://guides.rubyonrails.org/migrations.html#using-models-in-your-migrations
  class OrganizationType < ActiveRecord::Base; end
  class Organization < ActiveRecord::Base; end
  class Contact < ActiveRecord::Base; end

  def self.up
    organization_type = OrganizationType.find_by_name("GC Networks")
    organizations     = Organization.scoped(:conditions => {:organization_type_id => organization_type.id})
    contacts          = Contact.scoped(:conditions => {:organization_id => organizations.map(&:id)})

    puts "Setting organization_id to NULL on #{contacts.count} contacts"
    contacts.update_all("organization_id = NULL")

    puts "Deleting #{organizations.count} organizations"
    organizations.delete_all
  end

  def self.down
  end
end
