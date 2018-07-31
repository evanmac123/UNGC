# frozen_string_literal: true

require 'test_helper'

module Academy
  class SignInPolicyTest < ActiveSupport::TestCase

    test "it denies a contacts by default" do
      contact = create(:contact)
      policy = ::Academy::SignInPolicy.new

      refute policy.can_sign_in?(contact)
    end

    context "Organizations" do

      should "allow contacts from active, participant level organizations" do
        organization = create_organization(active: true, cop_state: "active",
          participant: true, level_of_participation: :participant_level)
        contact = create(:contact, organization: organization)
        policy = ::Academy::SignInPolicy.new

        assert policy.can_sign_in?(contact)
      end

      should "disallow contacts from inactive organizations" do
        organization = create_organization(active: false)
        contact = create(:contact, organization: organization)
        policy = ::Academy::SignInPolicy.new

        refute policy.can_sign_in?(contact)
      end

      should "disallow contacts from delisted organizations" do
        organization = create_organization(cop_state: Organization::COP_STATE_DELISTED)
        contact = create(:contact, organization: organization)
        policy = ::Academy::SignInPolicy.new

        refute policy.can_sign_in?(contact)
      end

      should "disallow contacts from signatory tier organizations" do
        organization = create_organization(level_of_participation: :signatory_level)
        contact = create(:contact, organization: organization)
        policy = ::Academy::SignInPolicy.new

        refute policy.can_sign_in?(contact)
      end

      should "disallow contacts from undecided organizations" do
        organization = create(:organization, level_of_participation: nil)
        contact = create(:contact, organization: organization)
        policy = ::Academy::SignInPolicy.new

        refute policy.can_sign_in?(contact)
      end

      should "disallow contacts from non-participant organizations" do
        organization = create(:organization, participant: false)
        contact = create(:contact, organization: organization)
        policy = ::Academy::SignInPolicy.new

        refute policy.can_sign_in?(contact)
      end
    end

    context "Staff" do

      should "allow staff contacts with the Academy Manager role" do
        academy_manager = create(:role, name: Role::FILTERS[:academy_manager])
        staff = create(:staff_contact, roles: [academy_manager])
        policy = ::Academy::SignInPolicy.new

        assert policy.can_sign_in?(staff)
      end

      should "disallow regular taff contacts" do
        staff = create(:staff_contact)
        policy = ::Academy::SignInPolicy.new

        refute policy.can_sign_in?(staff)
      end

    end

    context "Local Networks" do

      should "allow Local Network representatives to sign-in" do
        academy_role = create(:role, name: Role::FILTERS[:academy_local_network_representative])
        network = create(:local_network)
        contact = create(:contact, roles: [academy_role], local_network: network)
        policy = ::Academy::SignInPolicy.new

        assert policy.can_sign_in?(contact)
      end

      should "disallow regular local network contacts" do
        network = create(:local_network)
        contact = create(:contact, local_network: network)
        policy = ::Academy::SignInPolicy.new

        refute policy.can_sign_in?(contact)
      end

    end

    private

    def create_organization(params = {})
      defaults = {
        active: true,
        cop_state: Organization::COP_STATE_ACTIVE,
        participant: true,
        level_of_participation: :participant_level,
      }

      create(:organization, params.reverse_merge(defaults))
    end

  end
end
