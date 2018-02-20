require "test_helper"

module Crm
  class FunctionalTest < ActiveSupport::TestCase

    setup do
      Rails.configuration.x_enable_crm_synchronization = true
      TestAfterCommit.enabled = true
    end

    teardown do
      Rails.configuration.x_enable_crm_synchronization = false
      TestAfterCommit.enabled = false
    end


    test "creating an local network also creates it in the CRM" do
      crm = mock_restforce

      network = create(:local_network, name: "France")

      crm_network = crm.find_local_network(network.id)
      assert_not_nil crm_network
      assert_equal "France", crm_network.Name
    end

    test "updating a local network also updates it in the CRM" do
      crm = mock_restforce

      network = create(:local_network, name: "France")
      network.update!(name: "Belgium")

      crm_network = crm.find_local_network(network.id)
      assert_not_nil crm_network
      assert_equal "Belgium", crm_network.Name
    end

    test "deleting a local network marks it as deleted in the CRM" do
      crm = mock_restforce

      network = create(:local_network)
      network.destroy!

      crm_network = crm.find_local_network(network.id)
      assert_equal true, crm_network.IsDeleted
    end


    test "creating an organization also creates it in the CRM" do
      restforce = mock_restforce

      organization = create(:organization, :with_sector, name: "Test Org")

      account = restforce.find_account(organization.id)
      assert_not_nil account
      assert_equal "Test Org", account.Name
    end

    test "creating an organization with contacts also creates them in the CRM" do
      restforce = mock_restforce

      # Given an existing organization with contacts
      contact = build(:contact)
      create(:organization, :with_sector, contacts: [contact])

      # Then a contact is also added
      sf_contact = restforce.find_contact(contact.id)
      assert_not_nil sf_contact
    end

    test "updating an organization also updates it in the CRM" do
      restforce = mock_restforce

      organization = create(:organization, :with_sector, employees: 100)
      organization.update!(employees: 200)

      account = restforce.find_account(organization.id)
      assert_not_nil account
      assert_equal 200, account.NumberOfEmployees
    end

    test "destroying an organization also destroys it in the CRM" do
      # TODO: What to do with the contacts?
      restforce = mock_restforce

      organization = create(:organization, :with_sector,
                            contacts: [
                                build(:contact_point, :financial_contact, organization: nil),
                                build(:contact, :financial_contact),
                            ]
      )

      contact_point = organization.contacts.contact_points.first
      contact = organization.contacts.financial_contacts.first

      refute_nil restforce.find_account(organization.id)
      refute_nil restforce.find_contact(contact_point.id)
      refute_nil restforce.find_contact(contact.id)

      organization.destroy

      assert_empty organization.errors.full_messages

      assert_nil restforce.find_account(organization.id)
      refute_nil restforce.find_contact(contact_point.id)
      refute_nil restforce.find_contact(contact.id)
    end

    test "creating a contact also creates it in the CRM" do
      restforce = mock_restforce

      organization = create(:organization, :with_sector,
                            contacts: [
                                build(:contact, first_name: "Alice", last_name: "Walker"),
                            ]
      )

      contact = organization.contacts.first

      sf_contact = restforce.find_contact(contact.id)
      assert_not_nil sf_contact
      assert_equal "Alice", sf_contact.FirstName
      assert_equal "Walker", sf_contact.LastName
    end

    test "updating a contact also updates it in the CRM" do
      restforce = mock_restforce

      organization = create(:organization, :with_sector,
                            contacts: [
                                build(:contact, phone: "123-456-7890"),
                            ]
      )

      contact = organization.contacts.first
      contact.update!(phone: "098-765-4321")

      sf_contact = restforce.find_contact(contact.id)

      assert_not_nil sf_contact
      assert_equal "098-765-4321", sf_contact.Phone
    end

    test "destroying a contact also destroys it in the CRM" do
      restforce = mock_restforce
      organization = create(:organization, :with_sector,
                             contacts: [
                                 build(:contact),
                                 build(:contact, :financial_contact),
                             ]
                           )

      refute_nil restforce.find_account(organization.id)

      organization.contacts.ids.each do |contact_id|
        refute_nil restforce.find_contact(contact_id)
      end

      contact = Contact.find(organization.contacts.financial_contacts.first)

      contact.destroy

      assert_empty contact.errors.full_messages

      assert_nil restforce.find_contact(contact.id)
    end

    test "creating an Action Platform also creates it in the CRM" do
      crm = mock_restforce

      platform = create(:action_platform_platform,
                        name: "One",
                        description: "description",
                        discontinued: true)

      crm_platform = crm.find_action_platform(platform.id)
      assert_not_nil crm_platform
      assert_equal "One", crm_platform.Name
      assert_equal "description", crm_platform.Description__c
      assert_equal "discontinued", crm_platform.Status__c
    end

    test "updating a Action Platform also updates it in the CRM" do
      crm = mock_restforce

      platform = create(:action_platform_platform, name: "One")
      platform.update!(name: "Two")

      crm_platform = crm.find_action_platform(platform.id)
      assert_not_nil crm_platform
      assert_equal "Two", crm_platform.Name
    end

    test "updating a Action Platform also updates it in the CRM" do
      crm = mock_restforce

      platform = create(:action_platform_platform, name: "One")
      platform.update!(name: "Two")

      crm_platform = crm.find_action_platform(platform.id)
      assert_not_nil crm_platform
      assert_equal "Two", crm_platform.Name
    end

    test "creating a Subscription also creates it in the CRM" do
      crm = mock_restforce

      contact = create(:contact_point, organization: create(:organization, :with_sector))

      subscription = create(:action_platform_subscription,
                            created_at: DateTime.new(2017, 3, 4, 17, 45, 0),
                            starts_on: DateTime.new(2018, 1, 1),
                            expires_on: Date.new(2018, 3, 4),
                            state: :approved,
                            organization: contact.organization,
                            contact: contact)

      crm_subscription = crm.find_action_platform_subscription(subscription.id)
      assert_not_nil crm_subscription
      assert_not_nil crm_subscription.Id
      assert_equal "2017-03-04T17:45:00.000Z", crm_subscription.Created_at__c
      assert_equal "2018-01-01", crm_subscription.Starts_On__c
      assert_equal "2018-03-04", crm_subscription.Expires_On__c
      assert_equal "approved", crm_subscription.Status__c
      assert_equal subscription.id, crm_subscription.UNGC_AP_Subscription_ID__c
      assert_not_nil crm_subscription.Action_Platform__c
      assert_not_nil crm_subscription.Contact_Point__c
      assert_not_nil crm_subscription.Organization__c
    end

    test "updating a Subscription also updates it in the CRM" do
      crm = mock_restforce

      subscription = create(:action_platform_subscription, :approved,
                            starts_on: "2018-01-01", expires_on: "2018-03-04")
      subscription.update!(expires_on: "2019-01-01")

      sub = crm.find_action_platform_subscription(subscription.id)
      assert_not_nil sub
      assert_equal "approved", sub.Status__c
    end

    test "deleting an Subscription marks it as deleted in the CRM" do
      crm = mock_restforce

      subscription = create(:action_platform_subscription, :approved)
      subscription.destroy!

      crm_subscription = crm.find_action_platform_subscription(subscription.id)
      assert_nil crm_subscription
    end

    test "only approved subscriptions are synced" do
      _crm = mock_restforce

      approved = build(:action_platform_subscription, state: :approved)
      pending = build(:action_platform_subscription, state: :pending)

      assert Crm::ActionPlatform::SubscriptionSyncJob.perform_now(:should_sync?, approved)
      refute Crm::ActionPlatform::SubscriptionSyncJob.perform_now(:should_sync?, pending)
    end

    private

    def mock_restforce
      restforce = ::FakeRestforce.new
      ::Restforce.expects(:new).returns(restforce).at_least(0)
      Crm::Salesforce.new(restforce)
    end

  end
end
