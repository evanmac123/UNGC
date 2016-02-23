require 'test_helper'

class SignInPolicyTest < ActiveSupport::TestCase

  setup do
    create_roles
  end

  context "Network report recipients" do

    should "be allowed to sign-in as Contact points from the same local network" do
      # Given a Network report recipient
      network = create_local_network
      nrr = create_contact(local_network: network, roles: [Role.network_report_recipient])

      # and a Contact points from an organization in the same local network
      country = create_country(local_network: network)
      organization = create_organization(country: country, state: :approved)
      cp = create_contact(organization: organization, roles: [Role.contact_point])

      policy = SignInPolicy.new(nrr)
      assert policy.can_sign_in_as?(cp)
    end

    should "NOT be allowed to sign-in as Contact points from another local network" do
      # Given a network report recipient
      network = create_local_network
      nrr = create_contact(local_network: network, roles: [Role.network_report_recipient])

      # and a contact in an organization outside of that network
      other_country = create_country(local_network: create_local_network)
      organization = create_organization(country: other_country, state: :approved)
      cp = create_contact(organization: organization, roles: [Role.contact_point])

      policy = SignInPolicy.new(nrr)
      refute policy.can_sign_in_as?(cp)
    end

    should "NOT be allowed to sign-in as a non-Contact points" do
      # Given a Network report recipient
      network = create_local_network
      nrr = create_contact(local_network: network, roles: [Role.network_report_recipient])

      # and a non-Contact points from an organization in the same local network
      country = create_country(local_network: network)
      organization = create_organization(country: country, state: :approved)
      cp = create_contact(organization: organization)

      policy = SignInPolicy.new(nrr)
      refute policy.can_sign_in_as?(cp)
    end

    should "allow Network report recipients to sign-in as Contact points in general" do
      # Given a Network report recipient
      nrr = create_contact(roles: [Role.network_report_recipient])

      policy = SignInPolicy.new(nrr)
      assert policy.can_sign_in_as_others?, "The Networt report recipient should be able to sign as Contact points"
    end

    should "exclude contacts from unapproved organizations" do
      # Given a network report recipient
      network = create_local_network
      country = create_country(local_network: network)
      contact = create_contact(local_network: network, roles: [Role.network_report_recipient])

      # and a contact in an organization from that network
      organization = create_organization(country: country, state: :rejected)
      other = create_contact(organization: organization, roles: [Role.contact_point])

      policy = SignInPolicy.new(contact)
      assert_not_includes policy.sign_in_targets, other
    end

    context "scoping down the organizations" do

      setup do
        # Given a network report recipient
        network = create_local_network
        country = create_country(local_network: network)
        contact = create_contact(local_network: network, roles: [Role.network_report_recipient])

        # Given some organizations in the network
        included_org =    create_organization(country: country, employees: 23, state: :approved)
        excluded_org =    create_organization(country: country, employees: 46, state: :approved)
        unapproved_org =  create_organization(country: country, employees: 23, state: :rejected)

        # with contact points
        @included = create_contact(organization: included_org, roles: [Role.contact_point])
        @excluded = create_contact(organization: excluded_org, roles: [Role.contact_point])
        @unapproved = create_contact(organization: unapproved_org, roles: [Role.contact_point])

        policy = SignInPolicy.new(contact)
        organization_scope = Organization.where(employees: 23)
        @contacts = policy.sign_in_targets(from: organization_scope)
      end

      should "include contacts from the organizations" do
        assert_includes @contacts, @included
      end

      should "exclude contacts from outside of those organizations" do
        assert_not_includes @contacts, @excluded
      end

      should "exclude contacts from unapproved organizations" do
        assert_not_includes @contacts, @unapproved
      end

    end


  end

  context "Staff" do

    should "be allowed to sign-in as any contact that can sign-in" do
      staff = create_staff_user
      policy = SignInPolicy.new(staff)

      other = create_contact(roles: [Role.network_guest_user])

      assert policy.can_sign_in_as? other
    end

  end

  should "NOT allow a non-Network report recipients to sign-in as anyone" do
    # Given a Network report recipient
    network = create_local_network
    nrr = create_contact(local_network: network)

    # and a non-Contact points from an organization in the same local network
    country = create_country(local_network: network)
    organization = create_organization(country: country, state: :approved)
    cp = create_contact(organization: organization, roles: [Role.contact_point])

    policy = SignInPolicy.new(nrr)
    refute policy.can_sign_in_as?(cp)
  end

end
