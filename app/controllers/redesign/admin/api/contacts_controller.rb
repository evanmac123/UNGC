class Redesign::Admin::Api::ContactsController < Redesign::Admin::ApiController

  def ungc
    contacts  = Contact.joins(:organization).where('organizations.name = ?', DEFAULTS[:ungc_organization_name])

    render_json contacts: contacts.map(&method(:serialize))
  end

  private

  def serialize(payload)
    ContactSerializer.new(payload).as_json
  end
end

