class RemoveLocalNetworkIdFromUngcContacts < ActiveRecord::Migration
  # local versions of the model classes, to avoid trampling by newer code
  # see: http://guides.rubyonrails.org/migrations.html#using-models-in-your-migrations
  class Organization < ActiveRecord::Base; end
  class Contact < ActiveRecord::Base; end
  
  def self.up
    ungc = Organization.find_by_name('UNGC')
    contacts  = Contact.scoped(:conditions => {:organization_id => ungc.id})
    contacts_updated = contacts.update_all("local_network_id = NULL")
    puts "Removed local_network_id from #{contacts_updated} UNGC contacts"
  end

  def self.down
  end
  
end
