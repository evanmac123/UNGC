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

    test "particpant users have the Participants branch name" do
      contact = create(:contact_point)
      assert contact.from_organization?

      branch_name = saml_encode(contact, "BranchName")
      assert_equal "Participants", branch_name
    end

    test "local network users have the Local Networks branch name" do
      network = create(:local_network)
      contact = create(:contact, local_network: network)
      assert contact.from_network?

      branch_name = saml_encode(contact, "BranchName")
      assert_equal "Local Networks", branch_name
    end

    test "staff have the UNGC Staff branch name" do
      contact = create(:staff_contact)
      assert contact.from_ungc?

      branch_name = saml_encode(contact, "BranchName")
      assert_equal "UNGC Staff", branch_name
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
