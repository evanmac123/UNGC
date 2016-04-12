require 'test_helper'

class VisibleToTest < ActiveSupport::TestCase
  setup do
    create(:organization_type)  # default org type
    create(:country)            # default country

    @france = create(:country, region: 'europe')
    @germany = create(:country, region: 'europe')
    @brazil = create(:country, region: 'latin_america')
    @colombia = create(:country, region: 'latin_america')

    @french_org = create(:organization, country: @france)
    @german_org = create(:organization, country: @germany)
    @brazilian_org = create(:organization, country: @brazil)
    @colombian_org = create(:organization, country: @colombia)
  end

  context "COPs" do
    setup do
      @french_cop = create_cop @french_org.id
      @german_cop = create_cop @german_org.id
      @brazilian_cop = create_cop @brazilian_org.id
      @colombian_cop = create_cop @colombian_org.id
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
      org_in_same_country = create(:organization, country: contact.local_network.country)
      from_same_country = create_cop org_in_same_country.id

      visible = CommunicationOnProgress.visible_to contact

      assert visible.include? from_same_country
      refute visible.include? @french_cop
      refute visible.include? @german_cop
    end

    should "only be from the same country as the regional center that a regional center contact belongs to" do
      regional_center = create(:local_network, state: :regional_center)

      @brazil.update_attribute(:regional_center, regional_center)
      @colombia.update_attribute(:regional_center, regional_center)

      contact = create(:contact, local_network: regional_center)

      visible = CommunicationOnProgress.visible_to contact

      assert visible.include? @brazilian_cop
      assert visible.include? @colombian_cop
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
      org_in_same_country = create(:organization, country: contact.local_network.country)

      visible = Organization.visible_to contact

      assert visible.include? org_in_same_country
      refute visible.include? @french_org
      refute visible.include? @german_org
    end

    should "only be from the same country as the regional center that a regional center contact belongs to" do
      regional_center = create(:local_network, state: :regional_center)

      @brazil.update_attribute(:regional_center, regional_center)
      @colombia.update_attribute(:regional_center, regional_center)

      contact = create(:contact, local_network: regional_center)

      visible = Organization.visible_to contact

      assert visible.include? @brazilian_org
      assert visible.include? @colombian_org
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
    local_network = create(:local_network)
    create(:country, local_network: local_network)
    contact = create(:contact, local_network: local_network)

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
    contact = create(:contact)
    assert_nil contact.user_type
    contact
  end

end
