class Contact::Updater

  def initialize(contact, policy)
    @contact = contact
    @policy = policy
  end

  def update(params)
    unless policy.can_update?(contact)
      contact.errors.add(:base, 'You are not authorized to edit that contact.')
      return false
    end
    
    if params[:password].try(:empty?)
      params.delete(:password)
    end

    if params[:image] && !policy.can_upload_image?(contact)
      params.delete(:image)
    end

    contact.update(params)
  end

  private

  attr_reader :policy, :contact

end
