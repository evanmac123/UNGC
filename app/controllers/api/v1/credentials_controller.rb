module Api::V1

  class CredentialsController < ApiController
    before_action :doorkeeper_authorize!
    respond_to :json

    def me
      contact = current_resource_owner
      respond_with(
        id: contact.id,
        name: contact.name_with_title,
        email: contact.email,
        organization_id: contact.organization_id,
        organization_name: contact.organization.name
      )
    end

  end

end
