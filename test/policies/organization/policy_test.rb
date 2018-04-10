require 'test_helper'

class Organization::PolicyTest < ActiveSupport::TestCase

  context "editing an organization's videos" do

    should "is allowed by UNGC staff" do
      organization = create(:organization)
      staff = create(:staff_contact)

      policy = Organization::Policy.new(organization, staff)
      assert policy.can_edit_video?
    end

    should "is not allowed by contacts from the organization" do
      contact = create(:contact)
      organization = create(:organization, contacts: [contact])

      policy = Organization::Policy.new(organization, contact)

      assert_not policy.can_edit_video?
    end

  end

  context "viewing exclusionary criteria" do

    should "is not allowed by just anyone" do
      contact = create(:contact)
      organization = create(:organization)
      policy = Organization::Policy.new(organization, contact)

      assert_not policy.can_view_exclusionary_criteria?
    end

    should "is allowed by UNGC staff" do
      contact = create(:staff_contact)
      organization = create(:organization)
      policy = Organization::Policy.new(organization, contact)

      assert policy.can_view_exclusionary_criteria?
    end

    should "is allowed by network contacts from the same local network" do
      network = create(:local_network)
      country = create(:country, local_network: network)
      contact = create(:contact, local_network: network)
      organization = create(:organization, country: country)

      policy = Organization::Policy.new(organization, contact)

      assert policy.can_view_exclusionary_criteria?
    end

    should "is allowed by contacts from the same organization" do
      organization = create(:organization)
      contact = create(:contact, organization: organization)

      policy = Organization::Policy.new(organization, contact)

      assert policy.can_view_exclusionary_criteria?
    end

  end

  context "editing exclusionary criteria" do

    should "is not allowed by default" do
      contact = create(:contact)
      organization = create(:organization)
      policy = Organization::Policy.new(organization, contact)

      assert_not policy.can_edit_exclusionary_criteria?
    end

    should "is allowed by Participant managers" do
      contact = create(:staff_contact, :participant_manager)
      organization = create(:organization)
      policy = Organization::Policy.new(organization, contact)

      assert policy.can_edit_exclusionary_criteria?
    end

    should "is allowed by Integrity managers" do
      contact = create(:staff_contact, :integrity_manager)
      organization = create(:organization)
      policy = Organization::Policy.new(organization, contact)

      assert policy.can_edit_exclusionary_criteria?
    end

  end

end
