class SamlIdpController < SamlIdp::IdpController

  def idp_authenticate(username, password)
    SamlUser.authenticate(username, password)
  end
  private :idp_authenticate

  def idp_make_saml_response(user)
    encode_response(user)
  end
  private :idp_make_saml_response

  def idp_logout
    # Unsupported
  end
  private :idp_logout

end
