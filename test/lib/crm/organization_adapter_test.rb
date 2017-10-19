require "test_helper"

module Crm
  class OrganizationAdapterTest < ActiveSupport::TestCase

    test "converts SMEs to Business Sector" do
      actual = convert_organization(organization_type: OrganizationType.sme)
      assert_equal "Business", actual.fetch("Sector__c")
    end

    test "converts Companies to Business Sector" do
      actual = convert_organization(organization_type: OrganizationType.company)
      assert_equal "Business", actual.fetch("Sector__c")
    end

    test "converts Micro-enterprises to Business Sector" do
      actual = convert_organization(organization_type:
        OrganizationType.micro_enterprise)
      assert_equal "Business", actual.fetch("Sector__c")
    end

    test "converts Non-Businesses to Non-business Sector" do
      organization_type = create(:organization_type,
        type_property: OrganizationType::NON_BUSINESS)
      actual = convert_organization(organization_type: organization_type)
      assert_equal "Non-business", actual.fetch("Sector__c")
    end

    test "converts id" do
      converted = convert_organization(id: 123)
      assert_equal 123, converted.fetch("UNGC_ID__c")
      assert_equal "123", converted.fetch("AccountNumber")
    end

    test "converts joined_on" do
      converted = convert_organization(joined_on: Date.new(2010, 2, 3))
      assert_equal "2010-02-03", converted.fetch("Join_Date__c")
    end

    test "converts organization type as Type" do
      converted = convert_organization(organization_type: OrganizationType.foundation)
      assert_equal "Foundation", converted.fetch("Type")
    end

    test "converts country name" do
      france = build_stubbed(:country, name: "France")
      converted = convert_organization(country: france)
      assert_equal "France", converted.fetch("Country__c")
    end

    test "converts organization name" do
      converted = convert_organization(name: "Pepsi")
      assert_equal "Pepsi", converted.fetch("Name")
    end

    test "converts sector to industry" do
      sector = Sector.find_by(name: "Beverages")
      converted = convert_organization(sector: sector)
      assert_equal "Beverages", converted.fetch("Industry")
    end

    test "converts employees" do
      converted = convert_organization(employees: 5342)
      assert_equal 5342, converted.fetch("NumberOfEmployees")
    end

    test "caps employees" do
      converted = convert_organization(employees: 376359317)
      assert_equal 99999999, converted.fetch("NumberOfEmployees")
    end

    test "converts revenue" do
      converted = convert_organization(revenue: 3)
      assert_equal "between USD 250 million and USD 1 billion",
        converted.fetch("Revenue__c")
    end

    test "converts precise_revenue to annual revenue" do
      revenue = Monetize.parse("$123,456,789,123,456,789")
      converted = convert_organization(precise_revenue: revenue)
      assert_equal 123456789123456789, converted.fetch("AnnualRevenue")
    end

    test "converts revenue to a dollar amount when precise_revenue is not available" do
      converted = convert_organization(
        precise_revenue: nil,
        revenue: 5,
        organization_type: OrganizationType.sme)
      assert_equal 5_000_000_000, converted.fetch("AnnualRevenue")
    end

    test "converts revenue to an empty string when neither are availble" do
      converted = convert_organization(
        precise_revenue: nil,
        revenue: nil,
        organization_type: OrganizationType.sme)
      assert_equal "", converted.fetch("AnnualRevenue")
    end

    test "revenue is 0 for organizations other than SMEs and Companies" do
      converted = convert_organization(
        revenue: 4,
        organization_type: OrganizationType.academic)

      assert_equal 0, converted.fetch("AnnualRevenue")
    end

    test "Revenue is Calculated when there is only bracketed revenue" do
      converted = convert_organization(precise_revenue: nil, revenue: 4)
      assert_equal true, converted.fetch("Revenue_is_Calculated__c")
    end

    test "Revenue is not Calculated when there is precise revenue" do
      converted = convert_organization(
        precise_revenue: Money.from_amount(1_000_000),
        revenue: 4)
      assert_equal false, converted.fetch("Revenue_is_Calculated__c")
    end

    test "converts is_ft_500" do
      converted = convert_organization(is_ft_500: true)
      assert_equal true, converted.fetch("FT500__c")
    end

    test "converts regions" do
      latin_country = create(:country, region: "latin_america")
      converted = convert_organization(country: latin_country)
      assert_equal "Latin America and the Caribbean", converted.fetch("Region__c")
    end

    test "converts cop_state" do
      converted = convert_organization(cop_state: "active")
      assert_equal "active", converted.fetch("COP_Status__c")
    end

    test "converts cop_due_on" do
      due_date = Date.new(2015, 4, 5)
      converted = convert_organization(cop_due_on: due_date)
      assert_equal "2015-04-05", converted.fetch("COP_Due_On__c")
    end

    test "converts last cop date" do
      organization = create(:organization)
      create_cop_on(organization, "2013-1-1")
      create_cop_on(organization, "2015-1-1")
      create_cop_on(organization, "2014-1-1")

      converted = convert_organization(organization)
      assert_equal "2015-01-01", converted.fetch("Last_COP_Date__c")
    end

    test "converts last cop differentiation" do
      organization = create(:organization)
      create(:communication_on_progress, organization: organization)
      converted = convert_organization(organization)
      assert_equal "learner", converted.fetch("Last_COP_Differentiation__c")
    end

    test "converts active" do
      converted = convert_organization(active: true)
      assert_equal true, converted.fetch("Active_c__c")
    end

    test "converts missing active" do
      converted = convert_organization(active: nil)
      assert_equal false, converted.fetch("Active_c__c")
    end

    test "converts joined year" do
      converted = convert_organization(joined_on: Date.new(2009, 2, 3))
      assert_equal 2009, converted.fetch("JoinYear__c")
    end

    test "converts listing statuses" do
      listing_status = build_stubbed(:listing_status, name: "sample")
      converted = convert_organization(listing_status: listing_status)
      assert_equal "sample", converted.fetch("Ownership")
    end

    test "converts delisted_on" do
      converted = convert_organization(delisted_on: Date.new(2015, 1, 2))
      assert_equal "2015-01-02", converted.fetch("Delisted_ON__c")
    end

    test "converts rejoined_on" do
      converted = convert_organization(rejoined_on: Date.new(2016, 2, 3))
      assert_equal "2016-02-03", converted.fetch("Rejoined_On__c")
    end

    test "converts is_local_network_member" do
      network = build_stubbed(:local_network)
      country = build_stubbed(:country, local_network: network)
      converted = convert_organization(country: country)
      assert_equal true, converted.fetch("Local_Network__c")
    end

    test "converts state" do
      converted = convert_organization(state: "pending_review")
      assert_equal "Pending Review", converted.fetch("State__c")
    end

    test "converts removal reason" do
      converted = convert_organization(removal_reason: RemovalReason.delisted)
      assert_equal "Expelled due to failure to communicate progress",
        converted.fetch("Removal_Reason__c")
    end

    test "converts isin" do
      converted = convert_organization(isin: "CH00CH00CH00")
      assert_equal "CH00CH00CH00", converted.fetch("ISIN__c")
    end

    test "converts billing street" do
      ceo = create(:contact, roles: [Role.ceo],
        address: "57517 Hills Spurs",
        address_more: "Suite 123")
      organization = create(:organization, contacts: [ceo])
      converted = convert_organization(organization)
      assert_equal "57517 Hills Spurs\nSuite 123",
        converted.fetch("BillingStreet")
    end

    test "converts billing city" do
      ceo = create(:contact, roles: [Role.ceo], city: "Toronto")
      organization = create(:organization, contacts: [ceo])
      converted = convert_organization(organization)
      assert_equal "Toronto", converted.fetch("BillingCity")
    end

    test "converts billing state" do
      ceo = create(:contact, roles: [Role.ceo], state: "OH")
      organization = create(:organization, contacts: [ceo])
      converted = convert_organization(organization)
      assert_equal "OH", converted.fetch("BillingState")
    end

    test "converts billing postal code" do
      ceo = create(:contact, roles: [Role.ceo], postal_code: "12345")
      organization = create(:organization, contacts: [ceo])
      converted = convert_organization(organization)
      assert_equal "12345", converted.fetch("BillingPostalCode")
    end

    test "truncates billing postal code" do
      ceo = create(:contact, roles: [Role.ceo],
        postal_code: "1234567890123456789012345")
      organization = create(:organization, contacts: [ceo])
      converted = convert_organization(organization)
      assert_equal "12345678901234567...", converted.fetch("BillingPostalCode")
    end

    test "converts billing country" do
      country = create(:country, name: "Canada")
      ceo = create(:contact, roles: [Role.ceo], country: country)
      organization = create(:organization, contacts: [ceo])
      converted = convert_organization(organization)
      assert_equal "Canada", converted.fetch("BillingCountry")
    end

    test "converts pledge at joining" do
      converted = convert_organization(pledge_amount: 12_500)
      assert_equal 12_500, converted.fetch("Pledge_at_Joining__c")
    end

    test "converts no pledge reasons" do
      converted = convert_organization(no_pledge_reason: "budget")
      assert_equal "We have not budgeted for a contribution this year",
        converted.fetch("Reason_for_no_pledge_at_joining__c")
    end

    test "converts OwnerId" do
      converted = convert_organization
      assert_equal "005A0000004KjLy", converted.fetch("OwnerId")
    end

    test "an organization with no signings" do
      converted = convert_organization

      expected = {
        'Anti_corruption__c' => false,
        'Board__c' => false,
        'B4P__c' => false,
        'C4C__c' => false,
        'CEO_Water_Mandate__c' => false,
        'GC100__c' => false,
        'LEAD__c' => false,
        'Human_Rights_WG__c' => false,
        'Social_Enterprise__c' => false,
        'Supply_Chain_AG__c' => false,
        'WEPs__c' => false,
      }
      actual = converted.slice(*expected.keys)
      assert_equal expected, actual
    end

    test "an organization with a few signings" do
      converted = convert_organization(signings: [
        sign(:weps),
        sign(:anti_corruption),
        sign(:gc100)
      ])

      expected = {
        'Anti_corruption__c' => true,
        'Board__c' => false,
        'GC100__c' => true,
        'Supply_Chain_AG__c' => false,
        'WEPs__c' => true,
      }
      actual = converted.slice(*expected.keys)
      assert_equal expected, actual
    end

    test "converts water_mandate to CEO_Water_Mandate__c" do
      converted = convert_organization(signings: [
        sign(:water_mandate)
      ])
      assert_equal true, converted.fetch("CEO_Water_Mandate__c")
    end

    test "converts non-endorsing water mandate to CEO_Water_Mandate__c" do
      converted = convert_organization(signings: [
        sign(:water_mandate_non_endorsing)
      ])
      assert_equal true, converted.fetch("CEO_Water_Mandate__c")
    end

    test "converts both water_mandate and non-endorsing water mandate to CEO_Water_Mandate__c" do
      converted = convert_organization(signings: [
        sign(:water_mandate),
        sign(:water_mandate_non_endorsing)
      ])

      assert_equal true, converted.fetch("CEO_Water_Mandate__c")
    end

    test "defaults Participant_Tier to unselected" do
      converted = convert_organization()
      assert_equal "Unselected", converted.fetch("Participant_Tier__c")
    end

    test "converts participant when there is a value" do
      converted = convert_organization(participant: false)
      assert_equal false, converted.fetch("Participant__c")
    end

    test "converts participant when there is no value" do
      converted = convert_organization(participant: nil)
      assert_equal false, converted.fetch("Participant__c")
    end

    test "converts level of participation" do
      converted = convert_organization(
        level_of_participation: :signatory_level)

      assert_equal "Signatory", converted.fetch("Participant_Tier_at_Joining__c")

      converted = convert_organization(
        level_of_participation: :participant_level)

      assert_equal "Participant", converted.fetch("Participant_Tier_at_Joining__c")
    end

    test "converts invoice date" do
      converted = convert_organization(invoice_date: Date.new(2020, 2, 3))
      assert_equal "2020-02-03", converted.fetch("Invoice_Date__c")
    end

    private

    def sign(initiative_symbol)
      create(:signing, initiative_id: Initiative::FILTER_TYPES[initiative_symbol])
    end

    def convert_organization(params = {})
      organization = if params.respond_to?(:id)
                       params # it is an organization
                     else
                       build_stubbed(:organization, params)
                     end
      adapter = Crm::OrganizationAdapter.new
      adapter.to_crm_params(organization)
    end

    def create_cop_on(organization, date_string)
      date = Date.parse(date_string).to_datetime
      create(:communication_on_progress, organization: organization,
        created_at: date, published_on: date.to_date)
    end

  end
end
