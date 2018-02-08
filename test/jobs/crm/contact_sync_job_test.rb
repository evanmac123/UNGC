require "test_helper"

module Crm
  class ContactSyncTest < ActiveSupport::TestCase

    test ".should_sync" do
      model = create(:contact)
      # No organization
      refute Crm::ContactSyncJob.perform_now(:should_sync?, model)

      # No organization sector
      model = create(:contact, organization: create(:organization))
      refute Crm::ContactSyncJob.perform_now(:should_sync?, model)

      # No organization sector
      model = create(:contact, organization: build(:organization, :with_sector))
      assert Crm::ContactSyncJob.perform_now(:should_sync?, model)
    end

    test "create a contact without an organization" do
      contact = create(:contact)

      assert_nil contact.record_id

      crm = mock("crm")
      Crm::ContactSyncJob.perform_now(:create, contact, {}, crm)

      contact.reload

      assert_nil contact.organization
      assert_nil contact.record_id
    end

    test "create a contact with an unsyncable organization" do
      contact = create(:contact, organization: build(:organization))

      assert_nil contact.record_id

      crm = mock("crm")

      Crm::ContactSyncJob.perform_now(:create, contact, {}, crm)

      contact.reload

      assert_nil contact.organization.record_id
      assert_nil contact.record_id
    end

    test "create a contact and organization (unsynced)" do
      contact = create(:contact_point, organization: build(:organization, :with_sector))

      org_record = Restforce::SObject.new(Id: '00D0D0000000001MVK')
      contact_record = Restforce::SObject.new(Id: '0030D0000000001MVK')

      crm = mock("crm")
      crm.expects(:log).with("creating Account-(#{contact.organization.id})")
      crm.expects(:find).with("Account", contact.organization.id.to_s, "UNGC_ID__c")
      crm.expects(:create).with("Account", anything).returns(org_record)
      crm.expects(:log).with("creating Contact-(#{contact.id})")
      crm.expects(:create).with do |object_name, params|
        object_name == 'Contact' &&
            params["UNGC_Contact_ID__c"] == contact.id &&
            params['AccountId'] == org_record.Id
      end.returns(contact_record)

      assert_nil contact.record_id
      assert_nil contact.organization.record_id

      Crm::ContactSyncJob.perform_now(:create, contact, {}, crm)

      contact.reload

      assert_equal contact.organization.record_id, org_record.Id
      assert_equal contact.record_id, contact_record.Id
    end

    test "create a contact with a synched organization" do
      contact = create(:contact_point, organization: build(:crm_organization))

      contact_record = Restforce::SObject.new(Id: '0030D0000000001MVK')

      crm = mock("crm")
      crm.expects(:log).with("creating Contact-(#{contact.id})")
      crm.expects(:create).with do |object_name, params|
        object_name == 'Contact' &&
            params["UNGC_Contact_ID__c"] == contact.id &&
            params['AccountId'] == contact.organization.record_id
      end.returns(contact_record)

      assert_nil contact.record_id

      org_record_id = contact.organization.record_id
      refute_nil org_record_id

      Crm::ContactSyncJob.perform_now(:create, contact, {}, crm)

      contact.reload

      assert_equal org_record_id, contact.organization.record_id
      assert_equal contact.record_id, contact_record.Id
    end

    test "update a contact without an organization" do
      contact = create(:contact, :with_record_id)

      assert_nil contact.organization
      refute_nil contact.record_id

      record_id = contact.record_id

      crm = mock("crm")
      Crm::ContactSyncJob.perform_now(:update, contact, {}, crm)

      contact.reload

      assert_nil contact.organization
      assert_equal record_id, contact.record_id
    end


    test "update a contact with an unsynchable organization" do
      contact = create(:contact, :with_record_id, organization: build(:organization, :with_record_id))

      refute_nil contact.organization
      refute_nil contact.organization.record_id
      refute_nil contact.record_id

      org_record_id = contact.organization.record_id
      record_id = contact.record_id

      crm = mock("crm")
      Crm::ContactSyncJob.perform_now(:update, contact, {}, crm)

      contact.reload

      assert_equal org_record_id, contact.organization.record_id
      assert_equal record_id, contact.record_id
    end

    test "update a contact and organization" do
      contact = create(:contact_point, :with_record_id, organization: build(:organization, :with_sector, :with_record_id))

      record_id = contact.record_id
      salesforce_contact = Restforce::SObject.new(Id: record_id)

      refute_nil contact.record_id
      org_record_id = contact.organization.record_id
      refute_nil org_record_id

      crm = mock("crm")
      crm.expects(:log).with("updating Contact-(#{contact.id})")
      crm.expects(:update).with do |object_name, record_id, params|
        object_name == 'Contact' &&
            params["UNGC_Contact_ID__c"] == contact.id &&
            !params.has_key?('AccountId')
      end.returns(salesforce_contact)

      Crm::ContactSyncJob.perform_now(:update, contact, {}, crm)

      contact.reload

      assert_equal org_record_id, contact.organization.record_id
      assert_equal contact.record_id, record_id
    end

    test "update a contact and an unsynched organization" do
      contact = create(:contact_point, :with_record_id, organization: build(:organization, :with_sector))

      record_id = contact.record_id
      salesforce_contact = Restforce::SObject.new(Id: record_id)

      org_record = Restforce::SObject.new(Id: '00D0D0000000001MVK')

      assert_nil contact.organization.record_id
      refute_nil contact.record_id

      crm = mock("crm")
      crm.expects(:log).with("creating Account-(#{contact.organization.id})")
      crm.expects(:find).with("Account", contact.organization.id.to_s, "UNGC_ID__c")
      crm.expects(:create).with("Account", anything).returns(org_record)
      crm.expects(:log).with("updating Contact-(#{contact.id})")
      crm.expects(:update).with do |object_name, record_id, params|
        object_name == 'Contact' &&
            params["UNGC_Contact_ID__c"] == contact.id &&
            params["AccountId"] == org_record.Id
      end.returns(salesforce_contact)

      Crm::ContactSyncJob.perform_now(:update, contact, {}, crm)

      contact.reload

      assert_equal org_record.Id, contact.organization.record_id
      assert_equal contact.record_id, record_id
    end

    test "update a contact that was synced but we don't have the record_id" do
      contact = create(:contact_point, organization: build(:crm_organization))

      contact_record = Restforce::SObject.new(Id: '0030D0000000001MVK')

      org_record_id = contact.organization.record_id
      refute_nil org_record_id
      assert_nil contact.record_id

      crm = mock("crm")
      crm.expects(:log).with("updating Contact-(#{contact.id})")
      crm.expects(:find).with("Contact", contact.id.to_s, "UNGC_Contact_ID__c").returns(contact_record)
      crm.expects(:update).with do |object_name, record_id, params|
        object_name == 'Contact' &&
            record_id == contact_record.Id
        params["UNGC_Contact_ID__c"] == contact.id &&
            !params.has_key?('AccountId')
      end.returns(contact_record)

      Crm::ContactSyncJob.perform_now(:update, contact, {}, crm)

      contact.reload

      assert_equal org_record_id, contact.organization.record_id
      assert_equal contact.record_id, contact_record.Id
    end

    test "updating a contact that isn't synced, creates it" do
      contact = create(:contact_point, organization: build(:crm_organization))

      contact_record = Restforce::SObject.new(Id: '0030D0000000001MVK')

      org_record_id = contact.organization.record_id
      refute_nil org_record_id
      assert_nil contact.record_id

      crm = mock("crm")
      crm.expects(:log).with("creating Contact-(#{contact.id})")
      crm.expects(:find).with("Contact", contact.id.to_s, "UNGC_Contact_ID__c")
      crm.expects(:create).with do |object_name, params|
        object_name == 'Contact' &&
            params["UNGC_Contact_ID__c"] == contact.id &&
            params["AccountId"] == org_record_id
      end.returns(contact_record)

      Crm::ContactSyncJob.perform_now(:update, contact, {}, crm)

      contact.reload

      assert_equal org_record_id, contact.organization.record_id
      assert_equal contact.record_id, contact_record.Id
    end

    test "destroy a contact" do
      contact = create(:contact, :with_record_id, organization: build(:organization))

      record_id = contact.record_id

      crm = mock("crm")
      crm.expects(:log)

      refute_nil record_id

      crm.expects(:destroy).returns(nil)
      assert_nil Crm::ContactSyncJob.perform_now(:destroy, nil, { record_id: contact.record_id }, crm)
    end

    test "create_contact can recover from a concurrency error by an update" do
      # Given a contact that we are attempting to create in the CRM
      contact = create(:contact_point, first_name: "Alice", last_name: "Walker", organization: build(:crm_organization))

      salesforce_id = "0038761200001lm9Kp"

      params = {
          'UNGC_Contact_ID__c' => contact.id,
          'FirstName' => 'Alice',
          'LastName' => 'Walker',
      }

      crm = mock("crm")

      crm.expects(:log).with("creating Contact-(#{contact.id})")

      # when we try to create the contact in the CRM,
      # someone else has beat us to it and we get a duplicate value error
      crm.expects(:create)
          .with('Contact', has_entries(params))
          .raises(Faraday::ClientError, "DUPLICATE_VALUE: duplicate value found: UNGC_Contact_ID__c duplicates value on record with id: #{salesforce_id}")

      crm.expects(:log).with("updating Contact-(#{contact.id})")
      # we then expect to retry as an update with the salesforce id
      crm.expects(:update).with("Contact", salesforce_id, has_entries(params))

      # try to create the contact
      contact.reload
      Crm::ContactSyncJob.perform_now(:create, contact, {}, crm)

      assert_equal contact.record_id, salesforce_id
    end
  end
end
