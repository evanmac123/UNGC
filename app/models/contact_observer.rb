class ContactObserver < ActiveRecord::Observer
  def before_destroy(contact)
     raise "Must have at least one contact" unless contact.organization.contacts.length > 0
  end
end
