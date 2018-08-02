# frozen_string_literal: true

module Saml
  class Authenticator

    class Issuer
      attr_reader :name, :sign_in_policy, :issuer_uris

      def initialize(name, sign_in_policy, issuer_uris)
        @name = name
        @sign_in_policy = sign_in_policy
        @issuer_uris = Array(issuer_uris)
      end

      delegate :can_sign_in?, to: :sign_in_policy
    end

    IglooIssuer = Issuer.new("Igloo Communities", Igloo::SignInPolicy.new,
      "https://unglobalcompact.igloocommunities.com/saml.digest"
    ).freeze

    DoceboIssuer = Issuer.new("The Academy", Academy::SignInPolicy.new, [
      "https://ungc.docebosaas.com/lms/index.php",
      "https://academy.unglobalcompact.org/lms/index.php",
      "http://academy.unglobalcompact.org/lms/index.php"
    ]).freeze

    Issuers = [IglooIssuer, DoceboIssuer].freeze

    def self.create_for(issuer_uri)
      issuer = Issuers.detect do |i|
        i.issuer_uris.include?(issuer_uri)
      end

      if issuer.present?
        new(issuer)
      else
        raise "Unexpected SAML Issuer: \"#{issuer_uri}\""
      end
    end

    def initialize(issuer)
      @issuer = issuer
    end

    def authenticate(username, password)
      contact = Contact.find_by(username: username)
      if can_sign_in_with?(contact, password)
        Saml::User.new(contact)
      end
    end

    def issuer_name
      @issuer.name
    end

    private

    def can_sign_in_with?(contact, password)
      contact&.valid_password?(password) &&
        @issuer.can_sign_in?(contact)
    end

  end
end
