class IglooContactsQuery

  def initialize(contact: nil)
    @contact = contact
  end

  def run
    result = Contact.where("updated_at >= ?", 5.minutes.ago).includes(:organization)
    result + updated_organization
  end

  def updated_organization
    contacts_that_may_have_new_organization_names = Organization.includes(:contacts)
    .where("updated_at >= ?", 5.minutes.ago).flat_map do |org|
      org.contacts
    end
    contacts_that_may_have_new_organization_names
  end


end
