require "test_helper"

module Crm
  class LocalNetworkAdapterTest < ActiveSupport::TestCase

    test "It converts local network id to the format that the CRM expects" do
      assert_equal "LN-1", Crm::Adapters::LocalNetwork.convert_id(1)
      assert_equal "LN-12", Crm::Adapters::LocalNetwork.convert_id(12)
      assert_equal "LN-123", Crm::Adapters::LocalNetwork.convert_id(123)
      assert_equal "LN-123456", Crm::Adapters::LocalNetwork.convert_id(123_456)
    end

    test "It converts RecordType" do
      assert_converts "RecordTypeId", "0121H000000rHIIQA2"
    end

    test "It converts Type" do
      assert_converts "Type", "UNGC Local Network"
      assert_converts "Type", "UNGC Regional Center", { state: :regional_center }
    end

    test "It converts long External_ID__c" do
      assert_converts "External_ID__c", "LN-123456", id: 123456
    end

    test "It converts Sector__c" do
      assert_converts "Sector__c", "Local_Network"
    end

    test "It converts OwnerId" do
      assert_converts "OwnerId", Crm::Owner::SALESFORCE_OWNER_ID
    end

    test "it converts Name" do
      assert_converts "Name", "France", name: "France"
    end

    test "It converts Launch Date" do
      assert_converts "Join_Date__c", "2011-02-28", { sg_local_network_launch_date: '2011-02-28' }
      assert_converts "JoinYear__c", 2011, { sg_local_network_launch_date: '2011-02-28' }
    end

    test "It converts Website" do
      assert_converts "Website", 'https://www.example.com', { url: 'https://www.example.com' }
    end

    test "It converts Region" do
      country = create(:country, :with_local_network, region: 'Narnia')
      local_network = country.local_network
      converted = Crm::Adapters::LocalNetwork.new(local_network).transformed_crm_params(:create)
      assert_equal 'Narnia', converted.fetch("Region__c")
    end

    test "it converts state" do
      assert_converts "State__c", "Emerging", state: :emerging
      assert_converts "State__c", "Active", state: :active
      assert_converts "State__c", "Advanced", state: :advanced
      assert_converts "State__c", "Inactive", state: :inactive
      assert_converts "State__c", "Regional Center", state: :regional_center
    end

    test "it converts business model" do
      assert_converts "Business_Model_LN__c", "N/A", business_model: nil
      assert_converts "Business_Model_LN__c", "Revenue Sharing", business_model: :revenue_sharing
      assert_converts "Business_Model_LN__c", "Global-Local", business_model: :global_local
      assert_converts "Business_Model_LN__c", "Not yet decided", business_model: :not_yet_decided
    end

    test "it converts Invoiced by" do
      assert_converts "To_Be_Invoiced_By_LN__c", "GCO", invoice_managed_by: :gco
      assert_converts "To_Be_Invoiced_By_LN__c", "Local Network", invoice_managed_by: :local_network
      assert_converts "To_Be_Invoiced_By_LN__c", "On hold", invoice_managed_by: :on_hold
      assert_converts "To_Be_Invoiced_By_LN__c", "1B+ by GCO & <1B by LN", invoice_managed_by: :global_or_local
      assert_converts "To_Be_Invoiced_By_LN__c", nil, invoice_managed_by: nil
    end

    private

    def assert_converts(key, expected_value, model_params = {})
      local_network = build_stubbed(:local_network, model_params)

      converted = Crm::Adapters::LocalNetwork.new(local_network).transformed_crm_params(:create)
      if expected_value.nil?
        assert_nil converted.fetch(key)
      else
        assert_equal expected_value, converted.fetch(key)
      end
    end

  end
end
