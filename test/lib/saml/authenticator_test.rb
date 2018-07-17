# frozen_string_literal: true

require "test_helper"

module Saml
  class AuthenticatorTest < ActiveSupport::TestCase

    test "It can create an authenticator for Igloo" do
      Authenticator.create_for(Authenticator::IglooIssuer)
    end

    test "It can create an authenticator for the Academy" do
      Authenticator.create_for(Authenticator::DoceboIssuer)
    end

    test "it wraps a valid contact in a Saml::User" do
      contact = create(:contact)
      policy = stub("policy", can_sign_in?: true)
      authenticator = Authenticator.new(policy)
      user = authenticator.authenticate(contact.username, contact.password)
      assert user.is_a?(Saml::User)
    end

    test "it authenticates contacts allowed by the policy" do
      contact = create(:contact)
      policy = stub("policy", can_sign_in?: true)
      authenticator = Authenticator.new(policy)
      assert_not_nil authenticator.authenticate(contact.username, contact.password)
    end

    test "it refuses contacts refused by the policy" do
      contact = create(:contact)
      policy = stub("policy", can_sign_in?: false)
      authenticator = Authenticator.new(policy)
      assert_nil authenticator.authenticate(contact.username, contact.password)
    end

    test "it denies a valid contact with the wrong password" do
      # Given a valid contact
      contact = create(:contact, password: "Passw0rd")

      # When we try to authenticate with her username and the wrong password
      policy = Igloo::SignInPolicy.new
      user = Authenticator.new(policy).authenticate(contact.username, "wrong")

      # Then we get nil back indicating that she has not been authenticated
      assert_nil user
    end

    test "it denies unknown contacts" do
      # When we try to authenticate a user that doesn't exist
      policy = Igloo::SignInPolicy.new
      user = Authenticator.new(policy).authenticate("doesnt_exist", "Passw0rd")

      # Then we get nil indicating that she has not been authenticated
      assert_nil user
    end

  end
end
