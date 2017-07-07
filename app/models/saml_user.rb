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

    if can_login?(contact)
      track_igloo_sign_in(contact)
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

  private

  def self.can_login?(contact)
    policy = Igloo::SignInPolicy.new
    policy.can_sign_in?(contact)
  end

  # keep track of which contacts have signed in via SAML
  # NB: this feature is to support manual activation of
  # Igloo accounts. Once we move past the initial phase and
  # implement a way to sync contacts, this can be removed.
  # It should also be noted that if we start using SAML for
  # features other than Igloo, this is going to going to get tangled up.
  def self.track_igloo_sign_in(contact)
    IglooSignInTracker.track(contact)
  end
end
