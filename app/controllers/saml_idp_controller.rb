# frozen_string_literal: true

class SamlIdpController < SamlIdp::IdpController
  layout 'application'

  before_action :assign_template

  protected

  def idp_authenticate(username, password)
    @saml_authenticator.authenticate(username, password)
  end

  def idp_make_saml_response(user)
    encode_response(user)
  end

  def idp_logout
    # No-op
  end

  def assign_template
    if @saml_request&.issuer.present?
      @saml_authenticator = Saml::Authenticator.create_for(@saml_request.issuer)
      @template = @saml_authenticator.issuer_token
    end
  end

end
