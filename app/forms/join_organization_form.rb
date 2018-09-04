class JoinOrganizationForm < Contact
  attr_accessor :country_name, :organization_name

  validates :organization_id, presence: true
  validates :country_id, presence: true

  def save
    existing_contact = Contact.find_by(
      email: email, organization_id: organization_id)

    if existing_contact
      self.id = existing_contact.id
      self.reload
    end

    if valid?
      publish_event
      send_email
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
      username: suggested_username
    }
  end

  private

  def publish_event
    if new_record?
      event = DomainEvents::Organization::ContactRequestedMembership.new(data: contact_attributes)
      EventPublisher.publish(event, to: organization.event_stream_name)
    else
      data = contact_attributes.merge(contact_id: id)
      event = DomainEvents::Organization::ContactClaimedUsername.new(data: data)
      EventPublisher.publish(event, to: organization.event_stream_name)
    end
  end

  def send_email
    if new_record?
      OrganizationMailer.request_to_join_organization(contact_attributes).deliver_later
    else
      data = contact_attributes.merge(id: id)
      OrganizationMailer.request_to_claim_username(data).deliver_later
    end
  end
end
