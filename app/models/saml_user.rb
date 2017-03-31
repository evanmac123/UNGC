class SamlUser
  attr_reader :contact

  delegate :id, :email, :first_name, :last_name, to: :contact

  def initialize(contact)
    @contact = contact
  end

  def self.authenticate(username, password)
    contact = Contact.find_by(username: username)
    return if contact.nil?
    return unless contact.valid_password?(password)

    if contact.from_ungc? || ActionPlatform::Subscription.where(contact: contact).any?
      self.new(contact)
    end
  end


  def asserted_attributes
    {
      Email: { getter: :email },
      FName: { getter: :first_name },
      LName: { getter: :last_name },
    }
  end
end
