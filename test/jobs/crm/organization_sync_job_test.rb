require "test_helper"

module Crm
  class OrganizationSyncTest < ActiveSupport::TestCase

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

      Crm::OrganizationSyncJob.perform_now(:create, organization, {}, crm)
      assert_equal record_id, organization.reload.record_id
    end

    test "create an organization with an unsynced local_network" do
      local_network = create(:local_network, :with_network_contact)
      organization = create(:organization, :with_sector,
                            country: create(:country, local_network: local_network))

      assert_nil organization.record_id
      assert_nil local_network.record_id

      sf_ln_id = "%03d" % local_network.id


      org_record_id = '00D0D0000000001LNW'
      ln_record_id =  '01I0D0000000001LNW'

      crm = mock("crm")

      crm.expects(:log).with("creating Local_Network__c-(#{local_network.id})")
      crm.expects(:log).with("creating Account-(#{organization.id})")

      crm.expects(:find).with("Local_Network__c", "LN-#{sf_ln_id}", "External_ID__c")
      crm.expects(:create).with("Local_Network__c", anything).returns(ln_record_id)
      crm.expects(:create).with do |object_name, params|
        object_name == 'Account' && params["Local_Network_Name__c"] == ln_record_id
      end.returns(org_record_id)

      Crm::OrganizationSyncJob.perform_now(:create, organization, {}, crm)

    end

    test "create an organization with a synced local_network" do
      local_network = create(:crm_local_network)
      organization = create(:organization, :with_sector,
                            country: create(:country, local_network: local_network))

      assert_nil organization.record_id

      org_record_id = '00D0D0000000001LNW'
      ln_record_id =  local_network.record_id

      crm = mock("crm")

      crm.expects(:log).with("creating Account-(#{organization.id})")

      crm.expects(:create).with do |object_name, params|
        object_name == 'Account' && params["Local_Network_Name__c"] == ln_record_id
      end.returns(org_record_id)

      Crm::OrganizationSyncJob.perform_now(:create, organization, {}, crm)

    end

    test "update a synced organization" do

      organization = create(:crm_organization)
      crm = mock("crm")
      crm.expects(:log)

      record_id = organization.record_id

      # first the account is found
      account = Restforce::SObject.new(Id: record_id)
      crm.expects(:update).with("Account", record_id, anything).returns(account)

      Crm::OrganizationSyncJob.perform_now(:update, organization, {}, crm)

      assert_equal record_id, organization.reload.record_id
    end

    test "update an organization with an unsynced local_network" do
      local_network = create(:local_network, :with_network_contact)
      organization = create(:crm_organization,
                            country: create(:country, local_network: local_network))

      refute_nil organization.record_id
      assert_nil local_network.record_id

      sf_ln_id = "%03d" % local_network.id

      org_record_id = organization.record_id
      ln_record_id =  '01I0D0000000001LNW'

      crm = mock("crm")

      crm.expects(:log).with("creating Local_Network__c-(#{local_network.id})")
      crm.expects(:log).with("updating Account-(#{organization.id})")

      crm.expects(:find).with("Local_Network__c", "LN-#{sf_ln_id}", "External_ID__c").returns(nil)
      crm.expects(:create).with("Local_Network__c", anything).returns(ln_record_id)
      crm.expects(:update).with do |object_name, sales_force_id, params|
        object_name == 'Account' &&
            sales_force_id == org_record_id &&
            params["Local_Network_Name__c"] == ln_record_id
      end.returns(org_record_id)

      Crm::OrganizationSyncJob.perform_now(:update, organization, {}, crm)

    end

    test "update an organization with a synced local_network, does not sync LN" do
      local_network = create(:crm_local_network)
      organization = create(:crm_organization, country: create(:country, local_network: local_network))

      refute_nil organization.record_id
      refute_nil local_network.record_id

      sf_ln_id = "%03d" % local_network.id

      org_record_id = organization.record_id
      ln_record_id =  local_network.record_id

      crm = mock("crm")

      crm.expects(:log).with("updating Account-(#{organization.id})")

      salesforce_org = Restforce::SObject.new(Id: org_record_id)

      crm.expects(:update).with do |object_name, sales_force_id, params|
        object_name == 'Account' &&
            sales_force_id == org_record_id &&
            !params.has_key?("Local_Network_Name__c")
      end.returns(salesforce_org)

      Crm::OrganizationSyncJob.perform_now(:update, organization, {}, crm)
    end

    test "destroy an organization" do
      organization = create(:crm_organization)
      crm = mock("crm")
      crm.expects(:log)

      salesforce_org = Restforce::SObject.new(Id: organization.record_id)

      crm.expects(:destroy).returns(nil)
      assert_nil Crm::OrganizationSyncJob.perform_now(:destroy, nil, { record_id: organization.record_id }, crm)
    end

    test "destroy an organization that doesn't exist in the CRM" do
      organization = create(:crm_organization)
      crm = mock("crm")
      crm.expects(:log)
      crm.expects(:destroy).returns(nil)
      assert_nil Crm::OrganizationSyncJob.perform_now(:destroy, nil, { record_id: organization.record_id }, crm)
    end

    test "create an organization can recover from a concurrency error by an update" do
      # Given a contact that we are attempting to create in the CRM
      organization = create(:organization, :with_sector)

      salesforce_id = "0038761200001lm9Kp"

      params = {
          'Account' => organization.id,
          'Name' => organization.name,
      }

      crm = mock("crm")

      crm.expects(:log).with("creating Account-(#{organization.id})")

      # when we try to create the contact in the CRM,
      # someone else has beat us to it and we get a duplicate value error
      crm.expects(:create)
          .with('Account', anything)
          .raises(Faraday::ClientError, "DUPLICATE_VALUE: duplicate value found: UNGC_ID__c duplicates value on record with id: #{salesforce_id}")

      crm.expects(:log).with("updating Account-(#{organization.id})")
      # we then expect to retry as an update with the salesforce id
      crm.expects(:update).with("Account", salesforce_id, anything)

      # try to create the contact
      Crm::OrganizationSyncJob.perform_now(:create, organization, {}, crm)

      assert_equal organization.record_id, salesforce_id
    end

  end
end
