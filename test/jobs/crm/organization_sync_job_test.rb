require 'minitest/autorun'

module Crm
  class OrganizationSyncTest < ActiveJob::TestCase

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
        assert_enqueued_with(job: Crm::OrganizationSyncJob) do
          create(:organization, :with_sector)
        end
      end

      should 'conditionally enqueue a job on update' do
        model = create(:organization, :with_sector, name: 'Apex, Inc.')

        assert_enqueued_with(job: Crm::OrganizationSyncJob) do
          model.update!(name: "Nadir, Inc.")
        end

        assert_no_enqueued_jobs do
          model.update!(name: "Nadir, Inc.")
          model.touch
        end
      end

      should 'conditionally enqueue a job on destroy' do
        model = create(:organization)

        assert_enqueued_with(job: Crm::OrganizationSyncJob) do
          model.destroy!
        end
      end

    end

    test "should_sync?" do
      organization = create(:organization, :with_sector)
      assert Crm::OrganizationSyncJob.perform_now(:should_sync?, organization)
    end

    test "create an organization" do
      organization = create(:organization, :with_sector)

      crm = mock("crm")
      crm.expects(:log)

      assert_nil organization.record_id

      record_id = '00D0D0000000001MVK'
      crm.expects(:create).with("Account", anything).returns(record_id)

      Crm::OrganizationSyncJob.perform_now(:create, organization, nil, crm)
      assert_equal record_id, organization.reload.record_id
    end

    test "create an organization with an unsynced local_network" do
      local_network = create(:local_network, :with_network_contact)
      organization = create(:organization, :with_sector,
                            country: create(:country, local_network: local_network))

      assert_nil organization.record_id
      assert_nil local_network.record_id

      sf_ln_id = "LN-#{local_network.id}"

      org_record_id = '00D0D0000000001LNW'
      ln_record_id =  '01I0D0000000001LNW'

      crm = mock("crm")

      crm.expects(:log).with("creating Account-(#{local_network.id}) LocalNetwork")
      crm.expects(:log).with("creating Account-(#{organization.id}) Organization")

      crm.expects(:find).with("Account", sf_ln_id, "External_ID__c")
      crm.expects(:create).with do |object_name, params|
        object_name == 'Account' &&
            params["External_ID__c"] == sf_ln_id &&
            params["Type"] == 'UNGC Local Network'
      end.returns(ln_record_id)

      crm.expects(:create).with do |object_name, params|
        object_name == 'Account' && params["Parent_LN_Account_Id__c"] == ln_record_id
      end.returns(org_record_id)

      Crm::OrganizationSyncJob.perform_now(:create, organization, nil, crm)

    end

    test "create an organization with a synced local_network" do
      local_network = create(:crm_local_network)
      organization = create(:organization, :with_sector,
                            country: create(:country, local_network: local_network))

      assert_nil organization.record_id

      org_record_id = '00D0D0000000001LNW'
      ln_record_id =  local_network.record_id

      crm = mock("crm")

      crm.expects(:log).with("creating Account-(#{organization.id}) Organization")

      crm.expects(:create).with do |object_name, params|
        object_name == 'Account' && params["Parent_LN_Account_Id__c"] == ln_record_id
      end.returns(org_record_id)

      Crm::OrganizationSyncJob.perform_now(:create, organization, nil, crm)

    end

    test "update a synced organization" do

      organization = build(:crm_organization)
      changes = organization.changes
      organization.save!

      crm = mock("crm")
      crm.expects(:log)

      record_id = organization.record_id

      # first the account is found
      account = Restforce::SObject.new(Id: record_id)
      crm.expects(:update).with("Account", record_id, anything).returns(account)

      Crm::OrganizationSyncJob.perform_now(:update, organization, changes, crm)

      assert_equal record_id, organization.reload.record_id
    end


    test "update an organization with an unsynced local_network" do
      local_network = create(:local_network, :with_network_contact)
      organization = build(:crm_organization,
                            country: create(:country, local_network: local_network))
      changes = organization.changes
      organization.save!

      refute_nil organization.record_id
      assert_nil local_network.record_id

      sf_ln_id = "LN-#{local_network.id}"

      org_record_id = organization.record_id
      ln_record_id =  '01I0D0000000001LNW'

      crm = mock("crm")

      crm.expects(:log).with("creating Account-(#{local_network.id}) LocalNetwork")
      crm.expects(:log).with("updating Account-(#{organization.id}) Organization")

      crm.expects(:find).with("Account", sf_ln_id, "External_ID__c").returns(nil)
      crm.expects(:create).with do |object_name, params|
        object_name == 'Account' &&
            params["External_ID__c"] == sf_ln_id &&
            params["Type"] == 'UNGC Local Network'
      end.returns(ln_record_id)
      crm.expects(:update).with do |object_name, sales_force_id, params|
        object_name == 'Account' &&
            sales_force_id == org_record_id &&
            params["Parent_LN_Account_Id__c"] == ln_record_id
      end.returns(org_record_id)

      Crm::OrganizationSyncJob.perform_now(:update, organization, changes, crm)

    end

    test "update an organization with a synced local_network, does not sync LN" do
      local_network = create(:crm_local_network)
      organization = build(:crm_organization, country: create(:country, local_network: local_network))
      changes = organization.changes
      organization.save!

      refute_nil organization.record_id
      refute_nil local_network.record_id

      sf_ln_id = "LN-#{local_network.id}"

      org_record_id = organization.record_id
      ln_record_id =  local_network.record_id

      crm = mock("crm")

      crm.expects(:log).with("updating Account-(#{organization.id}) Organization")

      salesforce_org = Restforce::SObject.new(Id: org_record_id)

      crm.expects(:update).with do |object_name, sales_force_id, params|
        object_name == 'Account' &&
            sales_force_id == org_record_id &&
            !params.has_key?("Local_Network_Name__c")
      end.returns(salesforce_org)

      Crm::OrganizationSyncJob.perform_now(:update, organization, changes, crm)
    end

    test "update is skipped if nothing was updated by ActiveRecord" do
      organization = build(:crm_organization)

      crm = mock("crm")
      crm.expects(:log).never
      crm.expects(:update).never

      Crm::OrganizationSyncJob.perform_now(:update, organization, nil, crm)
    end

    test "destroy an organization" do
      organization = create(:crm_organization)
      crm = mock("crm")
      crm.expects(:log)

      salesforce_org = Restforce::SObject.new(Id: organization.record_id)

      crm.expects(:destroy).returns(nil)
      assert_nil Crm::OrganizationSyncJob.perform_now(:destroy, nil, { record_id: [organization.record_id, nil] }, crm)
    end

    test "destroy an organization that doesn't exist in the CRM" do
      organization = create(:crm_organization)
      crm = mock("crm")
      crm.expects(:log)
      crm.expects(:destroy).returns(nil)
      assert_nil Crm::OrganizationSyncJob.perform_now(:destroy, nil, { record_id: [organization.record_id, nil] }, crm)
    end

    test "create an organization can recover from a concurrency error by an update" do
      # Given a contact that we are attempting to create in the CRM
      organization = build(:organization, :with_sector)
      changes = organization.changes
      organization.save!

      salesforce_id = "0038761200001lm9Kp"

      params = {
          'Account' => organization.id,
          'Name' => organization.name,
      }

      crm = mock("crm")

      crm.expects(:log).with("creating Account-(#{organization.id}) Organization")

      # when we try to create the contact in the CRM,
      # someone else has beat us to it and we get a duplicate value error
      crm.expects(:create)
          .with('Account', anything)
          .raises(Faraday::ClientError, "DUPLICATE_VALUE: duplicate value found: UNGC_ID__c duplicates value on record with id: #{salesforce_id}")

      crm.expects(:log).with("updating Account-(#{organization.id}) Organization")
      # we then expect to retry as an update with the salesforce id
      crm.expects(:update).with("Account", salesforce_id, anything)

      # try to create the contact
      Crm::OrganizationSyncJob.perform_now(:create, organization, changes, crm)

      assert_equal organization.record_id, salesforce_id
    end

  end
end
