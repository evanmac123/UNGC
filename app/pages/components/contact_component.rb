class ContactComponent
  def initialize(data)
    @data = data
  end

  def data
    contact_id = @data[:widget_contact][:contact_id] if @data[:widget_contact]
    return unless contact_id
    contact = Contact.find(contact_id)
    {
      photo: contact.image.url,
      name: contact.name,
      title: contact.job_title,
      email: contact.email,
      phone: contact.phone
    }
  end
end
