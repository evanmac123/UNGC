class RedesignPreview

  def self.permitted?(contact_or_id)
    return true if Rails.env.test?

    contact = if contact_or_id.respond_to?(:id)
      contact_or_id
    else
      Contact.find_by(id: contact_or_id)
    end

    contact && contact.from_ungc?
  end

end
