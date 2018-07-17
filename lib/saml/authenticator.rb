# frozen_string_literal: true

module Saml
  class Authenticator

    IglooIssuer = "https://unglobalcompact.igloocommunities.com/saml.digest"
    DoceboIssuer = "https://ungc.docebosaas.com/lms/index.php"

    def self.create_for(issuer)
      case issuer
        when IglooIssuer
          self.new(Igloo::SignInPolicy.new)
        when DoceboIssuer
          self.new(Academy::SignInPolicy.new)
        else
          raise "Unexpected SAML Issuer: \"#{issuer}\""
      end
    end

    def initialize(sign_in_policy)
      @sign_in_policy = sign_in_policy
    end

    def authenticate(username, password)
      contact = Contact.find_by(username: username)
      if can_sign_in_with?(contact, password)
        Saml::User.new(contact)
      end
    end

    private

    def can_sign_in_with?(contact, password)
      contact&.valid_password?(password) &&
        @sign_in_policy.can_sign_in?(contact)
    end

  end
end
