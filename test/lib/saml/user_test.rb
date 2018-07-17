# frozen_string_literal: true

require "test_helper"

module Saml
  class UserTest < ActiveSupport::TestCase

    test "exposes Email" do
      contact = create(:contact, email: "alice@example.com")
      email = saml_encode(contact, "Email")
      assert_equal "alice@example.com", email
    end

    test "exposes first name" do
      contact = create(:contact, first_name: "Alice")
      fname = saml_encode(contact, "FName")
      assert_equal "Alice", fname
    end

    test "exposes last name" do
      contact = create(:contact, last_name: "Walker")
      lname = saml_encode(contact, "LName")
      assert_equal "Walker", lname
    end

    test "exposes username" do
      contact = create(:contact, username: "alice123")
      username = saml_encode(contact, "Username")
      assert_equal "alice123", username
    end

    test "exposes company name" do
      organization = create(:organization)
      contact = create(:contact, organization: organization)
      company_name = saml_encode(contact, "CompanyName")
      assert_equal organization.name, company_name
    end

    private

    def saml_encode(contact, attribute)
      saml_user = Saml::User.new(contact)
      assertion_builder = SamlIdp::AssertionBuilder.new(nil, nil, saml_user, nil, nil, nil, nil, nil)
      doc = Nokogiri::XML(assertion_builder.raw)
      doc.remove_namespaces!
      xpath = "//Assertion/AttributeStatement/Attribute[@Name='#{attribute}']/AttributeValue"
      doc.search(xpath).first&.text
    end

  end
end
