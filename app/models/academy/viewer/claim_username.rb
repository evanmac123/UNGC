# frozen_string_literal: true

module Academy
  class Viewer::ClaimUsername

    def initialize(contact)
      @contact = contact
    end

    def execute
      if @contact.update(username: @contact.username)
        publish_event
        ask_staff_to_vet_new_contact
        @contact.send_reset_password_instructions
        [true, I18n.t("organization.successfully_claimed_contact")]
      else
        [false, ""]
      end
    end

    private

    def publish_event
      data = {
        contact_id: @contact.id,
        username: @contact.username
      }
      event = DomainEvents::Organization::ContactClaimedUsername.new(data: data)
      EventPublisher.publish(event, to: @contact.event_stream_name)
    end

    def ask_staff_to_vet_new_contact
      OrganizationMailer.vet_newly_claimed_username(@contact.id).deliver_later
    end

  end
end
