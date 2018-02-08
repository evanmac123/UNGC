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

    private

    def mock_restforce
      restforce = ::FakeRestforce.new
      ::Restforce.expects(:new).returns(restforce).at_least(0)
      restforce
    end

  end
end
