require "test_helper"
require "sidekiq/testing"

module Crm
  class FunctionalTest < ActiveSupport::TestCase

    setup do
      Sidekiq::Testing.inline!
      Crm::CommitHooks.run_in_tests = true
      TestAfterCommit.enabled = true
    end

    teardown do
      Sidekiq::Testing.fake!
      Crm::CommitHooks.run_in_tests = false
      TestAfterCommit.enabled = false
    end

    test "creating an organization also creates it in the CRM" do
      restforce = mock_restforce

      organization = create(:organization, name: "Test Org",
                           sector: build_stubbed(:sector))

      account = restforce.find_account(organization.id)
      assert_not_nil account
      assert_equal "Test Org", account.Name
    end

    test "creating an organization with contacts also creates them in the CRM" do
      restforce = mock_restforce

      # Given an existing organization with contacts
      contact = create(:contact)
      create(:organization, contacts: [contact],
             sector: build_stubbed(:sector))

      # Then a contact is also added
      sf_contact = restforce.find_contact(contact.id)
      assert_not_nil sf_contact
    end

    test "updating an organization also updates it in the CRM" do
      restforce = mock_restforce

      organization = create(:organization, employees: 100,
                           sector: build_stubbed(:sector))
      organization.update!(employees: 200)

      account = restforce.find_account(organization.id)
      assert_not_nil account
      assert_equal 200, account.NumberOfEmployees
    end

    test "destroying an organization also destroys it in the CRM" do
      restforce = mock_restforce

      organization = create(:organization, sector: build_stubbed(:sector))
      organization.destroy!

      account = restforce.find_account(organization.id)
      assert_nil account
    end

    test "creating a contact also creates it in the CRM" do
      restforce = mock_restforce

      contact = create(:contact, first_name: "Alice", last_name: "Walker")

      sf_contact = restforce.find_contact(contact.id)
      assert_not_nil sf_contact
      assert_equal "Alice", sf_contact.FirstName
      assert_equal "Walker", sf_contact.LastName
    end

    test "updating a contact also updates it in the CRM" do
      restforce = mock_restforce

      contact = create(:contact, phone: "123-456-7890")
      contact.update!(phone: "098-765-4321")

      sf_contact = restforce.find_contact(contact.id)
      assert_not_nil sf_contact
      assert_equal "098-765-4321", sf_contact.Phone
    end

    test "destroying a contact also destroys it in the CRM" do
      restforce = mock_restforce

      contact = create(:contact)
      contact.destroy!

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
