require "test_helper"

class SamlIdpControllerTest < ActionController::TestCase

  test "it authenticates a valid contact by username & password" do
    contact = create_contact

    login(contact.username, contact.password)

    failure_message = assigns(:saml_idp_fail_msg)
    assert_nil failure_message
  end

  test "it fails with a message" do
    contact = create_contact

    login(contact.username, "wrong")

    failure_message = assigns(:saml_idp_fail_msg)
    assert_equal "Incorrect email or password.", failure_message
  end

  test "it sends the contact's ID, Name and email" do
    contact = create_contact

    login(contact.username, contact.password)

    saml = parse(assigns(:saml_response))

    assert_equal contact.id.to_s, saml.name_id
    assert_equal contact.first_name, saml.attributes["FName"]
    assert_equal contact.last_name, saml.attributes["LName"]
    assert_equal contact.email, saml.attributes["Email"]
  end

  private

  def parse(response)
    OneLogin::RubySaml::Response.new(response)
  end

  def create_contact
    ungc = Organization.find_by(name: "UNGC")
    create(:contact, organization: ungc)
  end

  def login(username, password)
    post :create, email: username,
      password: password,
      SAMLRequest: make_saml_request
  end

  def make_saml_request
    auth_request = OneLogin::RubySaml::Authrequest.new
    settings = OneLogin::RubySaml::Settings.new
    settings.idp_sso_target_url = "/saml/auth"
    auth_url = auth_request.create(settings)
    CGI.unescape(auth_url.split("=").last)
  end

end
