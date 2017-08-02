require "test_helper"

module Crm
  class ContactSyncTest < ActiveSupport::TestCase

    test "create_contact can recover from a concurrency error" do
      # Given a contact that we are attempting to create in the CRM
      contact = build_stubbed(:contact, id: 123, first_name: "Alice", last_name: "Walker")
      salesforce_id = "0031200001lm9Kp"

      params = {
        'UNGC_Contact_ID__c' => contact.id,
        'FirstName' => 'Alice',
        'LastName' => 'Walker',
      }

      crm = mock("CRM")

      # the contact should not be found in the CRM
      crm.expects(:find_contact).with(contact.id).returns(nil)

      # when we try to create the contact in the CRM,
      # someone else has beat us to it and we get a duplicate value error
      crm.expects(:create).
        with('Contact', has_entries(params)).
        raises(Faraday::ClientError, "DUPLICATE_VALUE: duplicate value found: UNGC_Contact_ID__c duplicates value on record with id: #{salesforce_id}")

      # we then expect to retry as an update with the salesforce id
      crm.expects(:update).
        with("Contact", salesforce_id, has_entries(params))

      # try to create the contact
      sync = Crm::ContactSync.new(crm)
      sync.create(contact)
    end

    test "create_contact can recover from a concurrency error from an unknown source" do
      # Given a contact that we are attempting to create in the CRM
      contact = build_stubbed(:contact, id: 123, first_name: "Alice", last_name: "Walker")
      salesforce_id = "0031200001lm9Kp"

      params = {
        'UNGC_Contact_ID__c' => contact.id,
        'FirstName' => 'Alice',
        'LastName' => 'Walker',
      }

      crm = mock("CRM")

      # the contact should not be found in the CRM
      crm.expects(:find_contact).with(contact.id).returns(nil)

      # when we try to create the contact in the CRM,
      # someone else has beat us to it and we get a duplicate value error
      crm.expects(:create).
        with('Contact', has_entries(params)).
        raises(Faraday::ClientError, "DUPLICATE_VALUE: duplicate value found: unknown duplicates value on record with id: #{salesforce_id}")

      # we then expect to retry as an update with the salesforce id
      crm.expects(:update).
        with("Contact", salesforce_id, has_entries(params))

      # try to create the contact
      sync = Crm::ContactSync.new(crm)
      sync.create(contact)
    end
  end
end
