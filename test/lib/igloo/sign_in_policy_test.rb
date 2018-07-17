# frozen_string_literal: true

require 'test_helper'

module Igloo
  class SignInPolicyTest < ActiveSupport::TestCase

    test "it denies a normal contact" do
      contact = create(:contact)
      policy = Igloo::SignInPolicy.new

      refute policy.can_sign_in?(contact)
    end

    test "it allows staff to sign in" do
      staff = create(:staff_contact)
      policy = Igloo::SignInPolicy.new

      assert policy.can_sign_in?(staff)
    end

    test "it allows local network contacts to sign in" do
      # Given an active Local Network
      network = create(:local_network, state: :active)

      # And a contact from that network that can login
      contact = create(:contact, local_network: network,
        username: "Foo", password: "Passw0rd")

      # Then the policy should allow them to sign in
      policy = Igloo::SignInPolicy.new
      assert policy.can_sign_in?(contact)
    end

    test "it allows an action platform subscriber" do
      # Given an ActionPlatform
      platform = create(:action_platform_platform)

      # And a contact from an Organization
      organization = create(:organization)
      contact = create(:contact, organization: organization)

      # And a Subscription to that platform for that contact and organization
      create(:action_platform_subscription,
        contact: contact,
        organization: organization,
        platform: platform,
        state: :approved)

      policy = Igloo::SignInPolicy.new

      assert policy.can_sign_in?(contact)
    end

    test "queries are tried in order" do
      contact = create(:contact)

      log = []
      policy = Igloo::SignInPolicy.new(queries: [
        FakeQuery.new(:first, log, false),
        FakeQuery.new(:second, log, false)
      ])

      policy.can_sign_in?(contact)

      assert_equal [:first, :second], log
    end

    test "queries short circuit" do
      contact = create(:contact)

      log = []
      policy = Igloo::SignInPolicy.new(queries: [
        FakeQuery.new(:first, log, true),
        FakeQuery.new(:second, log, false)
      ])

      assert policy.can_sign_in?(contact)
      assert_equal [:first], log
    end

    private

    def valid_contact
      ungc = Organization.find_by(name: "UNGC")
      create(:contact, organization: ungc)
    end

    class FakeQuery
      def initialize(id, log, return_value)
        @id = id
        @log = log
        @return_value = return_value
      end

      def include?(_contact)
        @log << @id
        @return_value
      end
    end

  end
end
