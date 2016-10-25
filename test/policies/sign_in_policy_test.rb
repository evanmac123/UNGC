require 'test_helper'

class SignInPolicyTest < ActiveSupport::TestCase

  context "Network focal points" do

    should "be allowed to sign-in as Contact points from the same local network" do
      # Given a focal point
      network = create(:local_network)
      focal_point = create(:contact, local_network: network, roles: [Role.network_focal_point])

      # and Contact points from an organization in the same local network
      country = create(:country, local_network: network)
      organization = create(:organization, country: country, state: :approved)
      cp = create(:contact, organization: organization, roles: [Role.contact_point])

      # the focal point should be able to sign in as that contact point
      policy = SignInPolicy.new(focal_point)
      assert policy.can_sign_in_as?(cp)
    end

  end

  context "Network report recipients" do

    should "be allowed to sign-in as Contact points from the same local network" do
      # Given a Network report recipient
      network = create(:local_network)
      nrr = create(:contact, local_network: network, roles: [Role.network_report_recipient])

      # and a Contact points from an organization in the same local network
      country = create(:country, local_network: network)
      organization = create(:organization, country: country, state: :approved)
      cp = create(:contact, organization: organization, roles: [Role.contact_point])

      policy = SignInPolicy.new(nrr)
      assert policy.can_sign_in_as?(cp)
    end

    should "NOT be allowed to sign-in as Contact points from another local network" do
      # Given a network report recipient
      network = create(:local_network)
      nrr = create(:contact, local_network: network, roles: [Role.network_report_recipient])

      # and a contact in an organization outside of that network
      other_country = create(:country, local_network: create(:local_network))
      organization = create(:organization, country: other_country, state: :approved)
      cp = create(:contact, organization: organization, roles: [Role.contact_point])

      policy = SignInPolicy.new(nrr)
      refute policy.can_sign_in_as?(cp)
    end

    should "NOT be allowed to sign-in as a non-Contact points" do
      # Given a Network report recipient
      network = create(:local_network)
      nrr = create(:contact, local_network: network, roles: [Role.network_report_recipient])

      # and a non-Contact points from an organization in the same local network
      country = create(:country, local_network: network)
      organization = create(:organization, country: country, state: :approved)
      cp = create(:contact, organization: organization)

      policy = SignInPolicy.new(nrr)
      refute policy.can_sign_in_as?(cp)
    end

    should "allow Network report recipients to sign-in as Contact points in general" do
      # Given a Network report recipient
      nrr = create(:contact, roles: [Role.network_report_recipient])

      policy = SignInPolicy.new(nrr)
      assert policy.can_sign_in_as_others?, "The Networt report recipient should be able to sign as Contact points"
    end

    should "exclude contacts from rejected organizations" do
      # Given a network report recipient
      network = create(:local_network)
      country = create(:country, local_network: network)
      contact = create(:contact, local_network: network, roles: [Role.network_report_recipient])

      # and a contact in an organization from that network
      organization = create(:organization, country: country, state: :rejected)
      other = create(:contact, organization: organization, roles: [Role.contact_point])

      policy = SignInPolicy.new(contact)
      assert_not_includes policy.sign_in_targets, other
    end

    context "scoping down the organizations" do

      setup do
        # Given a Contact and a Country in the same Local Network
        network = create(:local_network)
        contact = create(:contact, local_network: network, roles: [Role.network_report_recipient])
        @country = create(:country, local_network: network)

        # And a policy for that contact
        @policy = SignInPolicy.new(contact)
      end

      should "include organizations that match the scope" do
        scope = Organization.where(employees: 23)
        contact = create_contact_point_from(@country, employees: 23)
        assert_includes @policy.sign_in_targets(from: scope), contact
      end

      should "exclude organizations that don't match the scope" do
        scope = Organization.where(employees: 23)
        contact = create_contact_point_from(@country, employees: 46)
        assert_not_includes @policy.sign_in_targets(from: scope), contact
      end

      should "include pending_review organizations" do
        contact = create_contact_point_from(@country, state: :pending_review)
        assert_includes @policy.sign_in_targets, contact
      end

      should "include in_review organizations" do
        contact = create_contact_point_from(@country, state: :in_review)
        assert_includes @policy.sign_in_targets, contact
      end

      should "include network_review organizations" do
        contact = create_contact_point_from(@country, state: :network_review)
        assert_includes @policy.sign_in_targets, contact
      end

      should "include delay_review organizations" do
        contact = create_contact_point_from(@country, state: :delay_review)
        assert_includes @policy.sign_in_targets, contact
      end

      should "include approved organizations" do
        contact = create_contact_point_from(@country, state: :approved)
        assert_includes @policy.sign_in_targets, contact
      end

      should "exclude rejected organizations" do
        contact = create_contact_point_from(@country, state: :rejected)
        assert_not_includes @policy.sign_in_targets, contact
      end

    end

  end

  context "Staff" do

    should "be allowed to sign-in as any contact that can sign-in" do
      staff = create_staff_user
      policy = SignInPolicy.new(staff)

      other = create(:contact, roles: [Role.network_guest_user])

      assert policy.can_sign_in_as? other
    end

  end

  should "NOT allow a non-Network report recipients to sign-in as anyone" do
    # Given a Network report recipient
    network = create(:local_network)
    nrr = create(:contact, local_network: network)

    # and a non-Contact points from an organization in the same local network
    country = create(:country, local_network: network)
    organization = create(:organization, country: country, state: :approved)
    cp = create(:contact, organization: organization, roles: [Role.contact_point])

    policy = SignInPolicy.new(nrr)
    refute policy.can_sign_in_as?(cp)
  end

  private

  def create_contact_point_from(country, params = {})
    org = create(:organization, params.reverse_merge(country: country))
    create(:contact, organization: org, roles: [Role.contact_point])
  end

end
