module Academy
  class Viewer < ::Contact
    attr_accessor :country_name, :organization_name

    validates :organization, presence: true

    def can_login?
      true
    end

    def password_required?
      false
    end

    def save
      if country_id.blank? && country_name.present?
        self.country = Country.find_by(name: country_name)
      end

      if organization_id.blank? && organization_name.present?
        self.organization = Organization.find_by(name: organization_name)
      end

      existing_contact = Contact.find_by(
        email: email, organization_id: organization_id)

      if existing_contact
        self.id = existing_contact.id

        attrs = self.attributes
        self.reload
        assign_attributes(attrs)
      end

      if valid?
        invite_id = SecureRandom.hex.to_s
        publish_event(invite_id)
        send_email(invite_id)
        true
      end
    end

    def contact_attributes
      {
        organization_id: organization_id,
        prefix: prefix,
        first_name: first_name,
        middle_name: middle_name,
        last_name: last_name,
        job_title: job_title,
        email: email,
        phone: phone,
        address: address,
        address_more: address_more,
        city: city,
        state: state,
        postal_code: postal_code,
        country_id: country_id,
        username: username,
      }
    end

    private

    def publish_event(stream)
      if new_record?
        data = contact_attributes
        event = DomainEvents::Organization::ContactRequestedMembership.new(data: data)
        EventPublisher.publish(event, to: stream)
      else
        data = contact_attributes.merge(contact_id: id)
        event = DomainEvents::Organization::ContactRequestedLogin.new(data: data)
        EventPublisher.publish(event, to: stream)
      end
    end

    def send_email(invite_id)
      if new_record?
        OrganizationMailer.join_organization(invite_id, contact_attributes).deliver_later
      else
        data = contact_attributes.merge(id: id)
        OrganizationMailer.claim_username(invite_id, data).deliver_later
      end
    end
  end

end
