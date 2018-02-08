require "test_helper"

module Crm
  class LocalNetworkAdapterTest < ActiveSupport::TestCase

    test "It converts local network id to the format that the CRM expects" do
      assert_equal "LN-001", Crm::Adapters::LocalNetwork.convert_id(1)
      assert_equal "LN-012", Crm::Adapters::LocalNetwork.convert_id(12)
      assert_equal "LN-123", Crm::Adapters::LocalNetwork.convert_id(123)
    end

    test "It converts External_ID__c" do
      assert_converts "External_ID__c", "LN-123", id: 123
    end

    test "it converts Name" do
      assert_converts "Name", "France", name: "France"
    end

    test "it truncates name to 80 chars" do
      long_name = "A" * 90
      truncated = ("A" * 77) + "..."
      assert_converts "Name", truncated, name: long_name
    end

    test "it converts Country__c" do
      france = create(:country, name: "France")
      local_network = create(:local_network, countries: [france],
        invoice_managed_by: :on_hold)

      converted = Crm::Adapters::LocalNetwork.new(local_network).to_crm_params(:create)
      assert_equal "France", converted.fetch("Country__c")
    end

    test "it converts empty business models to N/A" do
      assert_converts "Business_Model__c", "N/A",
        business_model: nil
    end

    test "it converts Revenue Sharing" do
      assert_converts "Business_Model__c", "Revenue Sharing",
        business_model: :revenue_sharing
    end

    test "it converts Global-Local" do
      assert_converts "Business_Model__c", "Global-Local",
        business_model: :global_local
    end

    test "it converts Not yet decided" do
      assert_converts "Business_Model__c", "Not yet decided",
        business_model: :not_yet_decided
    end

    test "it converts GCO Invoiced by" do
      assert_converts "To_be_Invoiced_by__c", "GCO",
        invoice_managed_by: :gco
    end

    test "it converts Local Network Invoiced by" do
      assert_converts "To_be_Invoiced_by__c", "Local Network",
        invoice_managed_by: :local_network
    end

    test "it converts On hold Invoiced by" do
      assert_converts "To_be_Invoiced_by__c", "On hold",
        invoice_managed_by: :on_hold
    end

    test "it converts 1B+ by GCO & <1B by LN Invoiced by" do
      assert_converts "To_be_Invoiced_by__c", "1B+ by GCO & <1B by LN",
        invoice_managed_by: :global_or_local
    end

    private

    def assert_converts(key, expected_value, model_params = {})
      local_network = build_stubbed(:local_network, model_params)

      converted = Crm::Adapters::LocalNetwork.new(local_network).transformed_crm_params(:create)
      assert_equal expected_value, converted.fetch(key)
    end

  end
end
