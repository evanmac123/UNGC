require 'minitest/autorun'

module Crm
  class ContactSyncJobTest < ActiveJob::TestCase

    context 'jobs' do
      setup do
        Rails.configuration.x_enable_crm_synchronization = true
        TestAfterCommit.enabled = true
      end

      teardown do
        Rails.configuration.x_enable_crm_synchronization = false
        TestAfterCommit.enabled = false
      end

      should 'enqueue a job on create' do
        assert_enqueued_with(job: Crm::ContactSyncJob) do
          create(:contact, first_name: "Bobby", organization: nil, local_network: nil)
        end
      end

      should 'conditionally enqueue a job on update' do
        model = create(:contact, first_name: "Robert")

        assert_enqueued_with(job: Crm::ContactSyncJob) do
          model.update!(first_name: "Bobby")
        end

        assert_no_enqueued_jobs do
          model.update!(first_name: "Bobby")
        end

        assert_no_enqueued_jobs do
          model.update!(created_at: 1.year.from_now)
        end

        assert_no_enqueued_jobs do
          model.update!(updated_at: 1.year.from_now)
        end

        assert_no_enqueued_jobs do
          model.update!(last_sign_in_at: 1.year.from_now)
        end

        assert_no_enqueued_jobs do
          model.update!(current_sign_in_at: 1.year.from_now)
        end

        assert_no_enqueued_jobs do
          model.update!(sign_in_count: 100)
        end
      end
    end


    test ".should_sync" do
      model = create(:contact)
      # No organization
      refute Crm::ContactSyncJob.perform_now(:should_sync?, model)

      # No organization sector
      model = create(:contact, organization: create(:organization))
      assert Crm::ContactSyncJob.perform_now(:should_sync?, model)

      # With organization sector
      model = create(:contact, organization: build(:organization, :with_sector))
      assert Crm::ContactSyncJob.perform_now(:should_sync?, model)

      # With organization with no organization_type
      model = create(:contact, organization: build(:organization, organization_type_id: nil))
      refute Crm::ContactSyncJob.perform_now(:should_sync?, model)

      # With local_network
      model = create(:contact, local_network: build(:local_network))
      assert Crm::ContactSyncJob.perform_now(:should_sync?, model)

    end

    test "create a contact without an organization or local_network" do
      contact = create(:contact)

      assert_nil contact.record_id

      crm = mock("crm")
      crm.expects(:create).never
      Crm::ContactSyncJob.perform_now(:create, contact, nil, crm)

      contact.reload

      assert_nil contact.organization
      assert_nil contact.record_id
    end

    test "create a contact with an unsyncable organization" do
      contact = create(:contact, organization: build(:organization, organization_type_id: nil))

      assert_nil contact.record_id

      crm = mock("crm")

      Crm::ContactSyncJob.perform_now(:create, contact, nil, crm)

      contact.reload

      assert_nil contact.organization.record_id
      assert_nil contact.record_id
    end

    test "create a contact and organization (unsynced)" do
      contact = create(:contact_point, organization: build(:organization, :with_sector))

      org_record_id = '00D0D0000000001MVK'
      contact_record_id = '0030D0000000001MVK'

      crm = mock("crm")
      crm.expects(:log).with("creating Account-(#{contact.organization.id}) Organization")
      crm.expects(:find).with("Account", contact.organization.id.to_s, "UNGC_ID__c")
      crm.expects(:create).with("Account", anything).returns(org_record_id)
      crm.expects(:log).with("creating Contact-(#{contact.id}) Contact")
      crm.expects(:create).with do |object_name, params|
        object_name == 'Contact' &&
            params["UNGC_Contact_ID__c"] == contact.id &&
            params['AccountId'] == org_record_id
      end.returns(contact_record_id)

      assert_nil contact.record_id
      assert_nil contact.organization.record_id

      Crm::ContactSyncJob.perform_now(:create, contact, nil, crm)

      contact.reload

      assert_equal contact.organization.record_id, org_record_id
      assert_equal contact.record_id, contact_record_id
    end

    test "create a contact with a synched organization" do
      contact = create(:contact_point, organization: build(:crm_organization))

      contact_record_id = '0030D0000000001MVK'

      crm = mock("crm")
      crm.expects(:log).with("creating Contact-(#{contact.id}) Contact")
      crm.expects(:create).with do |object_name, params|
        object_name == 'Contact' &&
            params["UNGC_Contact_ID__c"] == contact.id &&
            params['AccountId'] == contact.organization.record_id
      end.returns(contact_record_id)

      assert_nil contact.record_id

      org_record_id = contact.organization.record_id
      refute_nil org_record_id

      Crm::ContactSyncJob.perform_now(:create, contact, nil, crm)

      contact.reload

      assert_equal org_record_id, contact.organization.record_id
      assert_equal contact.record_id, contact_record_id
    end

    test "update a contact without an organization or local_network" do
      contact = build(:contact, :with_record_id)
      changes = contact.changes
      contact.save!

      assert_nil contact.organization
      refute_nil contact.record_id

      record_id = contact.record_id

      crm = mock("crm")
      crm.expects(:update).never
      Crm::ContactSyncJob.perform_now(:update, contact, changes, crm)

      contact.reload

      assert_nil contact.organization
      assert_equal record_id, contact.record_id
    end

    test "update a contact with an unsynchable organization" do
      contact = build(:contact, :with_record_id, organization: build(:organization, :with_record_id, organization_type_id: nil))
      changes = contact.changes
      contact.save!

      refute_nil contact.organization
      refute_nil contact.organization.record_id
      refute_nil contact.record_id

      org_record_id = contact.organization.record_id
      record_id = contact.record_id

      crm = mock("crm")
      Crm::ContactSyncJob.perform_now(:update, contact, changes, crm)

      contact.reload

      assert_equal org_record_id, contact.organization.record_id
      assert_equal record_id, contact.record_id
    end

    test "update a contact and organization" do
      contact = build(:contact_point, :with_record_id, organization: build(:organization, :with_sector, :with_record_id))
      changes = contact.changes
      contact.save!

      record_id = contact.record_id
      salesforce_contact = Restforce::SObject.new(Id: record_id)

      refute_nil contact.record_id
      org_record_id = contact.organization.record_id
      refute_nil org_record_id

      crm = mock("crm")
      crm.expects(:log).with("updating Contact-(#{contact.id}) Contact")
      crm.expects(:update).with do |object_name, record_id, params|
        object_name == 'Contact' && !params.has_key?('AccountId')
      end.returns(salesforce_contact)

      Crm::ContactSyncJob.perform_now(:update, contact, changes, crm)

      contact.reload

      assert_equal org_record_id, contact.organization.record_id
      assert_equal contact.record_id, record_id
    end

    test "update a contact and an unsynched organization" do
      contact = build(:contact_point, :with_record_id, organization: build(:organization, :with_sector))
      changes = contact.changes
      contact.save!

      record_id = contact.record_id

      org_record_id = '00D0D0000000001MVK'

      assert_nil contact.organization.record_id
      refute_nil contact.record_id

      crm = mock("crm")
      crm.expects(:log).with("creating Account-(#{contact.organization.id}) Organization")
      crm.expects(:find).with("Account", contact.organization.id.to_s, "UNGC_ID__c")
      crm.expects(:create).with("Account", anything).returns(org_record_id)
      crm.expects(:log).with("updating Contact-(#{contact.id}) Contact")
      crm.expects(:update).with do |object_name, record_id, params|
        object_name == 'Contact' &&
            params["AccountId"] == org_record_id
      end.returns(record_id)

      Crm::ContactSyncJob.perform_now(:update, contact, changes, crm)

      contact.reload

      assert_equal org_record_id, contact.organization.record_id
      assert_equal contact.record_id, record_id
    end

    test "update a contact that was synced but we don't have the record_id" do
      contact = build(:contact_point, organization: build(:crm_organization))
      changes = contact.changes
      contact.save!

      contact_record = Restforce::SObject.new(Id: '0030D0000000001MVK')

      org_record_id = contact.organization.record_id
      refute_nil org_record_id
      assert_nil contact.record_id

      crm = mock("crm")
      crm.expects(:log).with("updating Contact-(#{contact.id}) Contact")
      crm.expects(:find).with("Contact", contact.id.to_s, "UNGC_Contact_ID__c").returns(contact_record)
      crm.expects(:update).with do |object_name, record_id, params|
        object_name == 'Contact' &&
            record_id == contact_record.Id
      end.returns(contact_record)

      Crm::ContactSyncJob.perform_now(:update, contact, changes, crm)

      contact.reload

      assert_equal org_record_id, contact.organization.record_id
      assert_equal contact.record_id, contact_record.Id
    end

    test "updating a contact that isn't synced, creates it" do
      contact = build(:contact_point, organization: build(:crm_organization))
      changes = contact.changes
      contact.save!

      contact_record_id = '0030D0000000001MVK'

      org_record_id = contact.organization.record_id
      refute_nil org_record_id
      assert_nil contact.record_id

      crm = mock("crm")
      crm.expects(:log).with("creating Contact-(#{contact.id}) Contact")
      crm.expects(:find).with("Contact", contact.id.to_s, "UNGC_Contact_ID__c")
      crm.expects(:create).with do |object_name, params|
        object_name == 'Contact'
      end.returns(contact_record_id)

      Crm::ContactSyncJob.perform_now(:update, contact, changes, crm)

      contact.reload

      assert_equal org_record_id, contact.organization.record_id
      assert_equal contact.record_id, contact_record_id
    end

    test "destroy a contact" do
      contact = create(:contact, :with_record_id, organization: build(:organization))

      record_id = contact.record_id

      crm = mock("crm")
      crm.expects(:log)

      refute_nil record_id

      crm.expects(:destroy).returns(nil)
      assert_nil Crm::ContactSyncJob.perform_now(:destroy, nil, { record_id: [contact.record_id, nil] }, crm)
    end

    test "create_contact can recover from a concurrency error by an update" do
      # Given a contact that we are attempting to create in the CRM
      contact = build(:contact_point, first_name: "Alice", last_name: "Walker", organization: build(:crm_organization))
      changes = contact.changes
      contact.save!

      salesforce_id = "0038761200001lm9Kp"

      params = {
          'FirstName' => 'Alice',
          'LastName' => 'Walker',
      }

      crm = mock("crm")

      crm.expects(:log).with("creating Contact-(#{contact.id}) Contact")

      # when we try to create the contact in the CRM,
      # someone else has beat us to it and we get a duplicate value error
      crm.expects(:create)
          .with('Contact', has_entries(params))
          .raises(Faraday::ClientError, "DUPLICATE_VALUE: duplicate value found: UNGC_Contact_ID__c duplicates value on record with id: #{salesforce_id}")

      crm.expects(:log).with("updating Contact-(#{contact.id}) Contact")
      # we then expect to retry as an update with the salesforce id
      crm.expects(:update).with("Contact", salesforce_id, has_entries(params))

      # try to create the contact
      contact.reload
      Crm::ContactSyncJob.perform_now(:create, contact, changes, crm)

      assert_equal contact.record_id, salesforce_id
    end

    # LOCAL NETWORK CONTACTS

    test "create a contact and local_network (unsynced)" do
      contact = create(:contact, local_network: build(:local_network))

      ln_record_id = '0010D0000000001MVK'
      contact_record_id = '0030D0000000001MVK'

      crm = mock("crm")
      crm.expects(:log).with("creating Account-(#{contact.local_network.id}) LocalNetwork")
      crm.expects(:find).with("Account", "LN-#{contact.local_network.id}", "External_ID__c")
      crm.expects(:create).with("Account", anything).returns(ln_record_id)
      crm.expects(:log).with("creating Contact-(#{contact.id}) Contact")
      crm.expects(:create).with do |object_name, params|
        object_name == 'Contact' &&
            params["UNGC_Contact_ID__c"] == contact.id &&
            params['AccountId'] == ln_record_id
      end.returns(contact_record_id)

      assert_nil contact.record_id
      assert_nil contact.local_network.record_id

      Crm::ContactSyncJob.perform_now(:create, contact, nil, crm)

      contact.reload

      assert_equal contact.local_network.record_id, ln_record_id
      assert_equal contact.record_id, contact_record_id
    end

    test "create a contact with a synched local_network" do
      contact = create(:contact, local_network: build(:local_network, :with_record_id))

      contact_record_id = '0030D0000000001MVK'

      crm = mock("crm")
      crm.expects(:log).with("creating Contact-(#{contact.id}) Contact")
      crm.expects(:create).with do |object_name, params|
        object_name == 'Contact' &&
            params["UNGC_Contact_ID__c"] == contact.id &&
            params['AccountId'] == contact.local_network.record_id
      end.returns(contact_record_id)

      assert_nil contact.record_id

      ln_record_id = contact.local_network.record_id
      refute_nil ln_record_id

      Crm::ContactSyncJob.perform_now(:create, contact, nil, crm)

      contact.reload

      assert_equal ln_record_id, contact.local_network.record_id
      assert_equal contact.record_id, contact_record_id
    end

    test "update a contact and local network" do
      contact = build(:contact, :with_record_id, local_network: build(:local_network, :with_record_id))
      changes = contact.changes
      contact.save!

      record_id = contact.record_id
      salesforce_contact = Restforce::SObject.new(Id: record_id)

      refute_nil contact.record_id
      ln_record_id = contact.local_network.record_id
      refute_nil ln_record_id

      crm = mock("crm")
      crm.expects(:log).with("updating Contact-(#{contact.id}) Contact")
      crm.expects(:update).with do |object_name, record_id, params|
        object_name == 'Contact'
      end.returns(salesforce_contact)

      Crm::ContactSyncJob.perform_now(:update, contact, changes, crm)

      contact.reload

      assert_equal ln_record_id, contact.local_network.record_id
      assert_equal contact.record_id, record_id
    end

    test "update a contact and an unsynched local_network" do
      contact = build(:contact, :with_record_id, local_network: build(:local_network))
      changes = contact.changes
      contact.save!

      record_id = contact.record_id

      ln_record_id = '00D0D0000000001MVK'

      assert_nil contact.local_network.record_id
      refute_nil contact.record_id

      crm = mock("crm")
      crm.expects(:log).with("creating Account-(#{contact.local_network.id}) LocalNetwork")
      crm.expects(:find).with("Account", "LN-#{contact.local_network.id}", "External_ID__c")
      crm.expects(:create).with("Account", anything).returns(ln_record_id)
      crm.expects(:log).with("updating Contact-(#{contact.id}) Contact")
      crm.expects(:update).with do |object_name, record_id, params|
        object_name == 'Contact' &&
            params["AccountId"] == ln_record_id
      end.returns(record_id)

      Crm::ContactSyncJob.perform_now(:update, contact, changes, crm)

      contact.reload

      assert_equal ln_record_id, contact.local_network.record_id
      assert_equal contact.record_id, record_id
    end

    test "update is skipped if nothing was updated by ActiveRecord" do
      contact = build(:contact, :with_record_id, local_network: build(:local_network, :with_record_id))

      crm = mock("crm")
      crm.expects(:log).never
      crm.expects(:update).never

      Crm::ContactSyncJob.perform_now(:update, contact, nil, crm)
    end
  end
end
