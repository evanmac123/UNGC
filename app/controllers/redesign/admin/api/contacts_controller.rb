class Redesign::Admin::Api::ContactsController < Redesign::Admin::ApiController

  def current
    render_json contact: serialize(current_contact).merge({
      is_website_editor: (current_contact.is? Role.website_editor)
    });
  end

  def index
    contacts  = Contact.joins(:organization).where('organizations.name = ?', DEFAULTS[:ungc_organization_name])

    render_json contacts: contacts.map(&method(:serialize))
  end

  private

  def serialize(payload)
    ContactSerializer.new(payload).as_json
  end
end
