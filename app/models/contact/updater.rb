class Contact::Updater

  def initialize(contact, policy)
    @contact = contact
    @policy = policy
  end

  def update(params)
    if params[:password].try(:empty?)
      contact_params.delete('password')
    end

    unless policy.can_upload_image?(contact)
      # TODO ensure this actually deletes image from the strong params object
      params.delete(:image)
    end

    if policy.can_update?(contact)
      contact.update(params)
    else
      contact.errors.add(:base, 'You are not authorized to edit that contact.')
      false
    end
  end

  private

  attr_reader :policy, :contact

end
