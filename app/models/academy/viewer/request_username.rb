# frozen_string_literal: true

module Academy
  class Viewer::RequestUsername

    def initialize(contact)
      @contact = contact
      @invite_id = SecureRandom.hex.to_s
    end

    def execute
      publish_event
      forward_invite_to_staff
      [true, I18n.t("organization.requested_to_join")]
    end

    def publish_event
      data = {
        contact_id: @contact.id,
        username: @contact.username,
      }
      event = DomainEvents::Organization::ContactRequestedLogin.new(data: data)
      EventPublisher.publish(event, to: @invite_id)
    end

    def forward_invite_to_staff
      OrganizationMailer.claim_username(@invite_id, contact_attributes).deliver_later
    end

    private

    def contact_attributes
      @contact.attributes.symbolize_keys.slice(
        :id,
        :organization_id,
        :prefix,
        :first_name,
        :middle_name,
        :last_name,
        :job_title,
        :email,
        :phone,
        :address,
        :address_more,
        :city,
        :state,
        :postal_code,
        :country_id,
        :username,
      )
    end

  end

end
