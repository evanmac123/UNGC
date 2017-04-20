class IglooContactsQuery

  def initialize(contact: nil)
    @contact = contact
  end

  def run
    result = Contact.where("updated_at >= ?", 5.minutes.ago).includes(:organization)
    result + updated_action_platform_organizations + updated_action_platform_contacts
    + action_platform_contacts + action_platform_organizations
  end

  def updated_organization
    contacts_that_may_have_new_organization_names = Organization.includes(:contacts)
    .where("updated_at >= ?", 5.minutes.ago).flat_map do |org|
      org.contacts
    end
    contacts_that_may_have_new_organization_names
  end

  def action_platform_contacts
    subscriptions = ActionPlatform::Subscription.all
    contacts = subscriptions.map do |subscription|
      subscription.contact
    end
    contacts
  end

  def action_platform_organizations
    subscriptions = ActionPlatform::Subscription.all
    organizations = subscriptions.map do |subscription|
      subscription.organization
    end
    organizations
  end

  def updated_action_platform_contacts
    ActionPlatform::Subscription.joins(:contact).where("contacts.updated_at >= ?", 5.minutes.ago)
  end

  def updated_action_platform_organizations
    ActionPlatform::Subscription.joins(:organization).where("organizations.updated_at >= ?", 5.minutes.ago)
  end




end
