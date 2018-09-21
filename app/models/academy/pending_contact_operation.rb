module Academy
  class PendingContactOperation
    attr_accessor :type, :attributes, :status, :contact

    def self.find(stream)
      events = EventPublisher.client.read_stream_events_forward(stream)
      new(stream, events)
    end

    def initialize(stream, events)
      @stream = stream
      events.each(&method(:apply))
    end

    def apply(event)
      self.attributes = event.data

      case event
      when DomainEvents::Organization::ContactRequestedMembership
        self.type = :new_contact
      when DomainEvents::Organization::ContactRequestedLogin
        self.type = :claim_username
      when DomainEvents::Organization::ContactClaimedUsername
        self.type = :claimed_username
      when DomainEvents::ContactCreated
        self.type = :contact_created
      when DomainEvents::Academy::ViewerAdded
      else
        raise "Unexpected event #{event}"
      end
    end

    def process
      case type
      when :new_contact
        accept_new_contact
      when :claim_username
        claim_username
      when :claimed_username
        @status = "We've assigned the contact a username and password. We've emailed them their credentials"
        @contact = Contact.find(attributes.fetch(:contact_id))
      when :contact_created
        @status = "The contact has been created and we've emailed them their credentials"
        @contact = Contact.find(attributes.fetch(:id))
      end
    end

    def accept_new_contact
      contact = Contact.new(attributes)
      contact.roles << Role.academy_viewer
      token = contact.send(:set_reset_password_token)
      contact.save!
      Academy::Mailer.welcome_new_user(contact, token).deliver_later

      data = attributes.merge(id: contact.id)
      event = DomainEvents::ContactCreated.new(data: data)
      EventPublisher.publish(event, to: @stream)

      event = DomainEvents::Academy::ViewerAdded.new(data: data)
      EventPublisher.publish(event, to: @stream)

      @status = "The contact has been created and we've emailed them their credentials"
      @contact = contact
    end

    def claim_username
      contact = Contact.find(attributes.fetch(:contact_id))
      contact.update!(username: attributes.fetch(:username))
      contact.send_reset_password_instructions

      data = { contact_id: contact.id, username: contact.username }
      event = DomainEvents::Organization::ContactClaimedUsername.new(data: data)
      EventPublisher.publish(event, to: @stream)

      @status = "We've assigned the contact a username and password. We've emailed them their credentials"
      @contact = contact
    end

  end
end
