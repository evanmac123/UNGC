SamlIdp.config.x509_certificate = <<EOS
EOS

SamlIdp.config.secret_key = <<EOS
EOS

SamlIdp.configure do |config|
  base = "http://example.com"

  config.x509_certificate = <<-CERT
-----BEGIN CERTIFICATE-----
MIIEEjCCAvqgAwIBAgIJALtZDhvt+lOCMA0GCSqGSIb3DQEBBQUAMGMxCzAJBgNV
BAYTAlVTMREwDwYDVQQIEwhOZXcgWW9yazERMA8GA1UEBxMITmV3IFlvcmsxGjAY
BgNVBAoTEVVOIEdsb2JhbCBDb21wYWN0MRIwEAYDVQQDEwlsb2NhbGhvc3QwHhcN
MTcwMzMwMjIwMzQ2WhcNMjAwMzI5MjIwMzQ2WjBjMQswCQYDVQQGEwJVUzERMA8G
A1UECBMITmV3IFlvcmsxETAPBgNVBAcTCE5ldyBZb3JrMRowGAYDVQQKExFVTiBH
bG9iYWwgQ29tcGFjdDESMBAGA1UEAxMJbG9jYWxob3N0MIIBIjANBgkqhkiG9w0B
AQEFAAOCAQ8AMIIBCgKCAQEAwxBbM5oYKQDRZFPxJOmC9BRD4Gepul0Z6QhRwQXd
Z7XXqGXFkSm/Y23ldeOxoEeSMkmVPp4YCfOSQCkOUdVHXPToutHO2Za0ERO2Vbwj
Us7nP1MDWjTL86vwwbeNxMaceH1VMJBv9ygYQ0+8EKeKyc3bzqDNqi/JiJqq2hoy
G2Vovmizbb/EPQyJ5XbAC82QgrWq93F2DFBjx7XAgTrSQKz97eUpWCi8uAoExSgw
Rkk8NxQUeZWgcu4+p8YL47we26mto3v+BN7dztA3rBIQLDvxHy31OEZ9tSvHe8MX
u510kdZEeKeaTofxXpGED2ZOqihhmPTjjHXuovryQa5lrwIDAQABo4HIMIHFMB0G
A1UdDgQWBBTrK5OcdU/ZD+HMglHJpAxj5AYrijCBlQYDVR0jBIGNMIGKgBTrK5Oc
dU/ZD+HMglHJpAxj5AYriqFnpGUwYzELMAkGA1UEBhMCVVMxETAPBgNVBAgTCE5l
dyBZb3JrMREwDwYDVQQHEwhOZXcgWW9yazEaMBgGA1UEChMRVU4gR2xvYmFsIENv
bXBhY3QxEjAQBgNVBAMTCWxvY2FsaG9zdIIJALtZDhvt+lOCMAwGA1UdEwQFMAMB
Af8wDQYJKoZIhvcNAQEFBQADggEBAAGhRgKaoOu64qiR1BygUasWRoKF6LwrqBeR
120iIZ4Z9BcFMXUJwMhydJzvlziACW+wu4nuFKfnamDxqU/WKpaXonvmUs7dn1Nz
gE5NSYJ4l5F8Pd9vNHe2Vpkvu/dw7j1GrB3RukwfQEhB5hjnXmGL5qMg2EffyAo9
Tnwvi+P2xK8R/Pgfpn3MRkQZehab1CyctsWhrHOVcy9T2bx0wwfA50dAgPdU0kss
5Ly/iQnndHdr+3N0yRzIekw+pNZHzjc60670j+KcNHmQrKosc9NCEND7Cfydn4/Q
P6F3zJsIRck3jylsX3qtr8b+rPCz2fO+d1lnck03UxJeY6TlKFM=
-----END CERTIFICATE-----
CERT

  config.secret_key = <<-CERT
-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEAwxBbM5oYKQDRZFPxJOmC9BRD4Gepul0Z6QhRwQXdZ7XXqGXF
kSm/Y23ldeOxoEeSMkmVPp4YCfOSQCkOUdVHXPToutHO2Za0ERO2VbwjUs7nP1MD
WjTL86vwwbeNxMaceH1VMJBv9ygYQ0+8EKeKyc3bzqDNqi/JiJqq2hoyG2Vovmiz
bb/EPQyJ5XbAC82QgrWq93F2DFBjx7XAgTrSQKz97eUpWCi8uAoExSgwRkk8NxQU
eZWgcu4+p8YL47we26mto3v+BN7dztA3rBIQLDvxHy31OEZ9tSvHe8MXu510kdZE
eKeaTofxXpGED2ZOqihhmPTjjHXuovryQa5lrwIDAQABAoIBAATZ/Uq1RHCQoqSa
Kd8/J5CmiGGmcmQ+OIzBNjdUzALuVOTNUzKfFTGF5DUgaqSP4yT5C4s5J2Pn+PU7
kC2c3l+Df95VpY1n4CaklN5hBYfjuYCrseOmeIQg/KX0yMPiJLYid+HzVbWR+7iA
3S6U3DDUu+jRuwvGkH6jSiiOijyAKA+uXXO0KB8U2lcWW7egxBP7kM6JEcNWn0xO
pzje4KEtltU51loVWQx69PrJdw4BpfYrSWNgx6r1R31XJ2ealdPMOlC+L72bQ7Ri
0pRvoFFJj+bpWwhSaHosNBPLMe8HHofqrCPme+5rQKQt2GRBxctWsVCYQ83Y8vs1
USHrv3ECgYEA6qsF0K6Wb46Pww0bxHsrkqghWMaf675bQcJ4l5CGVmQ5vTWPoN0L
nGWTbLe4R/seKqtZjUqy/V1ED2hJ/4WweJlDMItsEKkjmwYwB/DPYWFOCHmiZl8n
pR4GDcBqNbWsdMrhGr+RPQR7fGq3/BjMIHZKY3kvbyPrQdA2CLR8eOUCgYEA1Muz
v444v+mzhdVrMKbb1Ye1zpADb9ruwC+mxmJluHnJANPe3Z4G9fG3YrGlpSgxCqoA
VIHItzqUwTZGN+jiRrWrkz5OC4uh7RYg0e3MxeS0jcta4TIaAkag0UphuIaPsbcQ
KuO1VKqb1rrrWIQ9goYWbg8wgPSEQ0Hq3bwsXwMCgYArXLrQWtJ1frRV6IAvCEt+
6A5xZxJ570zRk+vQpeYM5Kw+qD0IDpBsr+BUAIbO1jo2zD7Z+umkI63F4xF5Y+y9
/CQMPlcTpQ1tQfFyJi9L4T0YF9HIdODQhAG+XMXDcvSRCEQcOzXNPpzK2rVwoexm
OzV3uBbpxIteN+kkJqWxeQKBgGVjsX9hylRWi70G1Q3XUwNIqC2FnL2c+QkFK1d2
5rShAk6spJG/i91/kDssHZq1rbhBC+s382SqOtpce9SD19yNDvUXSKRjoYGPe4/K
2DiqIgU1kVWfQ5k2AcX2xNzg8HJioQdue6WdrKcBZMVGLPCV5vYFsryexK4vKDMC
R7n1AoGAcDQICNa2FjD7Gj2cFAiAejkAr2gnEurHOLdea7ZL8k1MdSB7rzPnfleS
0FTtc8kTKsa/qR5pipCCNtcV+QnS+n2Jc4tHc/8pau6fhnv7aCea64SNsYa2bv75
KMQVdWVKvl3Vu8NFXEv5OnL7KXIwsxOPL3pAhTEXNJYFlMXykas=
-----END RSA PRIVATE KEY-----
CERT

  # config.password = "secret_key_password"
  # config.algorithm = :sha256
  # config.organization_name = "Your Organization"
  # config.organization_url = "http://example.com"
  # config.base_saml_location = "#{base}/saml"
  # config.reference_id_generator                   # Default: -> { UUID.generate }
  # config.attribute_service_location = "#{base}/saml/attributes"
  # config.single_service_post_location = "#{base}/saml/auth"

  # Principal (e.g. User) is passed in when you `encode_response`
  config.name_id.formats = {
    # email_address: -> (principal) { principal.email_address },
    # transient: -> (principal) { principal.id },
    persistent: -> (p) { p.id },
  }

  # If Principal responds to a method called `asserted_attributes`
  # the return value of that method will be used in lieu of the
  # attributes defined here in the global space. This allows for
  # per-user attribute definitions.
  #
  ## EXAMPLE **
  # class User
  #   def asserted_attributes
  #     {
  #       phone: { getter: :phone },
  #       email: {
  #         getter: :email,
  #         name_format: Saml::XML::Namespaces::Formats::NameId::EMAIL_ADDRESS,
  #         name_id_format: Saml::XML::Namespaces::Formats::NameId::EMAIL_ADDRESS
  #       }
  #     }
  #   end
  # end
  #
  # If you have a method called `asserted_attributes` in your Principal class,
  # there is no need to define it here in the config.

  # config.attributes # =>
  #   {
  #     <friendly_name> => {                                                  # required (ex "eduPersonAffiliation")
  #       "name" => <attrname>                                                # required (ex "urn:oid:1.3.6.1.4.1.5923.1.1.1.1")
  #       "name_format" => "urn:oasis:names:tc:SAML:2.0:attrname-format:uri", # not required
  #       "getter" => ->(principal) {                                         # not required
  #         principal.get_eduPersonAffiliation                                # If no "getter" defined, will try
  #       }                                                                   # `principal.eduPersonAffiliation`, or no values will
  #    }                                                                      # be output
  #
  ## EXAMPLE ##
  # config.attributes = {
  #   GivenName: {
  #     getter: :first_name,
  #   },
  #   SurName: {
  #     getter: :last_name,
  #   },
  # }
  ## EXAMPLE ##

  # config.technical_contact.company = "Example"
  # config.technical_contact.given_name = "Jonny"
  # config.technical_contact.sur_name = "Support"
  # config.technical_contact.telephone = "55555555555"
  # config.technical_contact.email_address = "example@example.com"

  service_providers = {
    "some-issuer-url.com/saml" => {
      fingerprint: "9E:65:2E:03:06:8D:80:F2:86:C7:6C:77:A1:D9:14:97:0A:4D:F4:4D",
      metadata_url: "http://some-issuer-url.com/saml/metadata"
    },
  }

  # `identifier` is the entity_id or issuer of the Service Provider,
  # settings is an IncomingMetadata object which has a to_h method that needs to be persisted
  config.service_provider.metadata_persister = ->(identifier, settings) {
    fname = identifier.to_s.gsub(/\/|:/,"_")
    `mkdir -p #{Rails.root.join("cache/saml/metadata")}`
    File.open Rails.root.join("cache/saml/metadata/#{fname}"), "r+b" do |f|
      Marshal.dump settings.to_h, f
    end
  }

  # `identifier` is the entity_id or issuer of the Service Provider,
  # `service_provider` is a ServiceProvider object. Based on the `identifier` or the
  # `service_provider` you should return the settings.to_h from above
  config.service_provider.persisted_metadata_getter = ->(identifier, service_provider){
    fname = identifier.to_s.gsub(/\/|:/,"_")
    `mkdir -p #{Rails.root.join("cache/saml/metadata")}`
    full_filename = Rails.root.join("cache/saml/metadata/#{fname}")
    if File.file?(full_filename)
      File.open full_filename, "rb" do |f|
        Marshal.load f
      end
    end
  }

  # Find ServiceProvider metadata_url and fingerprint based on our settings
  config.service_provider.finder = ->(issuer_or_entity_id) do
    service_providers[issuer_or_entity_id]
  end
end
