# frozen_string_literal: true

module Academy
  class Viewer::CreateNewContact

    def initialize(contact)
      @contact = contact
    end

    def execute
      token = Contact.transaction do
        @contact.roles << Role.academy_viewer
        @contact.send(:set_reset_password_token)
      end
      publish_event
      ask_staff_to_vet_new_contact
      send_welcome_email(token)
      [true, I18n.t("organization.successfully_created_contact")]
    end

    private

    def publish_event
      data = contact_attributes
      event = DomainEvents::ContactCreated.new(data: data)
      EventPublisher.publish(event, to: @contact.event_stream_name)
    end

    def ask_staff_to_vet_new_contact
      OrganizationMailer.vet_newly_created_contact(@contact.id).deliver_later
    end

    def send_welcome_email(token)
      Academy::Mailer.welcome_new_user(@contact, token).deliver_later
    end

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
