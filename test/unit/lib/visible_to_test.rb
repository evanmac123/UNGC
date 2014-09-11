require 'test_helper'

class VisibleToTest < ActiveSupport::TestCase
  setup do
    create_organization_type  # default org type
    create_country            # default country

    @france = create_country region: 'europe'
    @germany = create_country region: 'europe'

    @french_org = create_organization country: @france
    @german_org = create_organization country: @germany
  end

  context "COPs" do
    setup do
      @french_cop = create_cop @french_org.id
      @german_cop = create_cop @german_org.id
    end

    should "only be from the same organization as an organization contact" do
      contact = create_organization_contact
      from_own_organization = create_cop contact.organization.id

      visible = CommunicationOnProgress.visible_to contact

      assert visible.include? from_own_organization
      refute visible.include? @french_cop
      refute visible.include? @german_cop
    end

    should "only be from the same country as the local network that a network contact belongs to" do
      contact = create_network_contact
      org_in_same_country = create_organization country: contact.local_network.country
      from_same_country = create_cop org_in_same_country.id

      visible = CommunicationOnProgress.visible_to contact

      assert visible.include? from_same_country
      refute visible.include? @french_cop
      refute visible.include? @german_cop
    end

    should "include all for ungc contacts" do
      contact = create_ungc_contact

      visible = CommunicationOnProgress.visible_to contact

      assert visible.include? @french_cop
      assert visible.include? @german_cop
    end

    should "not include any for other types" do
      contact = create_other_contact

      visible = CommunicationOnProgress.visible_to contact

      assert_equal 0, visible.count
    end

  end

  context "Organizations" do


    should "only be the contact's organization" do
      contact = create_organization_contact

      visible = Organization.visible_to contact

      assert_equal contact.organization, visible.first
      assert_equal 1, visible.count
    end

    should "only be from the same country as the local network that a network contact belongs to" do
      contact = create_network_contact
      org_in_same_country = create_organization country: contact.local_network.country

      visible = Organization.visible_to contact

      assert visible.include? org_in_same_country
      refute visible.include? @french_org
      refute visible.include? @german_org
    end

    should "include all for ungc contacts" do
      contact = create_ungc_contact

      visible = Organization.visible_to contact

      assert visible.include? @french_org
      assert visible.include? @german_org
    end

    should "not include any for other types" do
      contact = create_other_contact

      visible = Organization.visible_to contact

      assert_equal 0, visible.count
    end

  end

  private

  def create_organization_contact
    # a contact that belongs to an organization
    contact = create_organization_and_user
    assert_equal Contact::TYPE_ORGANIZATION, contact.user_type
    assert_not_nil contact.organization
    contact
  end

  def create_network_contact
    # a contact and a country that belong to a local network
    local_network = create_local_network
    create_country(local_network: local_network)
    contact = create_contact(local_network: local_network)

    assert_equal Contact::TYPE_NETWORK, contact.user_type
    assert_not_nil contact.local_network.country
    contact
  end

  def create_ungc_contact
    # a staff contact
    contact = create_staff_user
    assert_equal Contact::TYPE_UNGC, contact.user_type
    contact
  end

  def create_other_contact
    # a contact from a country
    contact = create_contact
    assert_nil contact.user_type
    contact
  end

end
