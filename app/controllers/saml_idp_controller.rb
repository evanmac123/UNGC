# frozen_string_literal: true

class SamlIdpController < SamlIdp::IdpController
  layout 'application'

  def new
    saml_authenticator = Saml::Authenticator.create_for(@saml_request.issuer)
    @template = saml_authenticator.issuer_token
    super
  end

  protected

  def idp_authenticate(username, password)
    saml_authenticator = Saml::Authenticator.create_for(@saml_request.issuer)
    @template = saml_authenticator.issuer_token
    saml_authenticator.authenticate(username, password)
  end

  def idp_make_saml_response(user)
    encode_response(user)
  end

  def idp_logout
    # No-op
  end

end
