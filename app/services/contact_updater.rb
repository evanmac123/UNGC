class ContactUpdater < SimpleDelegator

  def initialize(contact, current_contact)
    super(contact)
    @current_contact = current_contact
  end

  def create
    unless policy.can_upload_image?(contact)
      contact.image = nil
    end

    if policy.can_create?(contact)
      contact.save
    else
      contact.errors.add(:base, 'You are not authorized to create that contact.')
      false
    end
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
      contact.errors.add(:base, 'You are not authorized to edit that contact.'
      false
    end
  end

  private

  attr_reader :current_contact

  def contact
    __getobj__
  end

  def policy
    @policy ||= ContactPolicy.new(current_contact)
  end

end
