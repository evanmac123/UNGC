# frozen_string_literal: true

require 'test_helper'

module Academy
  class SignInPolicyTest < ActiveSupport::TestCase

    test "it denies a normal contact" do
      contact = create(:contact)
      policy = ::Academy::SignInPolicy.new

      refute policy.can_sign_in?(contact)
    end

    test "it allows staff to sign in" do
      staff = create(:staff_contact)
      policy = ::Academy::SignInPolicy.new

      assert policy.can_sign_in?(staff)
    end

    test "it allows local network contacts to sign in" do
      # Given an active Local Network
      network = create(:local_network, state: :active)

      # And a contact from that network that can login
      contact = create(:contact, local_network: network,
        username: "Foo", password: "Passw0rd")

      # Then the policy should allow them to sign in
      policy = ::Academy::SignInPolicy.new
      assert policy.can_sign_in?(contact)
    end

    test "it allows contacts from participant tier organizations" do
      organization = create(:organization, level_of_participation: :participant_level)
      contact = create(:contact, organization: organization)
      policy = ::Academy::SignInPolicy.new

      assert policy.can_sign_in?(contact)
    end

    test "it disallows contacts from signatory organizations" do
      organization = create(:organization, level_of_participation: :signatory_level)
      contact = create(:contact, organization: organization)
      policy = ::Academy::SignInPolicy.new

      refute policy.can_sign_in?(contact)
    end

    test "it disallows contacts from undecided organizations" do
      organization = create(:organization, level_of_participation: nil)
      contact = create(:contact, organization: organization)
      policy = ::Academy::SignInPolicy.new

      refute policy.can_sign_in?(contact)
    end

  end
end
