module Academy
  class ViewersController < ApplicationController

    def new
      @viewer = Viewer.new
    end

    def create
      @viewer = Viewer.new(viewer_params)

      if @viewer.save
        redirect_to new_academy_viewer_url, notice: I18n.t("organization.requested_to_join")
      else
        render :new
      end
    end

    def accept
      stream_id = params.fetch(:viewer_id)
      events = EventPublisher.client.read_stream_events_forward(stream_id)

      events.each do |event|
        case event
        when DomainEvents::Organization::ContactRequestedMembership
          accept_new_contact(event.data)
        when DomainEvents::Organization::ContactClaimedUsername
          claim_username(event.data)
        else
          raise "unexpected event: #{event.class}"
        end
      end
    end

    private

    def accept_new_contact(attributes)
      contact = Contact.new(attributes)
      contact.roles << Role.academy_viewer
      token = contact.send(:set_reset_password_token)
      contact.save!
      Academy::Mailer.welcome_new_user(contact, token).deliver_later

      render text: "The contact has been created and we've emailed them their credentials"
    end

    def claim_username(attributes)
      contact = Contact.find(attributes.fetch(:contact_id))
      contact.update!(username: attributes.fetch(:username))
      contact.send_reset_password_instructions

      render text: "We've assigned the contact a username and password. We've emailed them their credentials"
    end

    def find_organization
      Organization.find(viewer_params.fetch(:organization_id))
    end

    def viewer_params
      params.require(:viewer).permit(
        :organization_id,
        :organization_name,
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
        :country_name,
        :username,
      )
    end

  end
end
