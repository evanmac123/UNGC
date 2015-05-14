class Components::Contact
  def initialize(data)
    @data = data
  end

  def data
    contact_id = @data[:widget_contact][:contact_id] if @data[:widget_contact]
    return unless contact_id
    contact = Contact.find(contact_id)
    {
      photo: contact.image,
      name: contact.full_name_with_title,
      title: contact.job_title,
      email: contact.email,
      phone: contact.phone
    }
  end
end
