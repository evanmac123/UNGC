require 'test_helper'

class SdgPioneer::EligibleBusinessesQueryTest < ActiveSupport::TestCase

  should 'include Micro Enterprises' do
    create(:organization_type, name: OrganizationType::FILTERS.fetch(:micro_enterprise))
    micro_enterprise = create_micro_enterprise

    results = SdgPioneer::EligibleBusinessesQuery.new.run
    assert_includes results, micro_enterprise
  end

  should 'include SMEs' do
    create(:organization_type, name: OrganizationType::FILTERS.fetch(:sme))
    sme = create_sme

    results = SdgPioneer::EligibleBusinessesQuery.new.run
    assert_includes results, sme
  end

  should 'include Companies' do
    create(:organization_type, name: OrganizationType::FILTERS.fetch(:companies))
    company = create_company

    results = SdgPioneer::EligibleBusinessesQuery.new.run
    assert_includes results, company
  end

  should 'NOT include non-businesses' do
    non_business = create(:non_business)
    results = SdgPioneer::EligibleBusinessesQuery.new.run
    assert_not_includes results, non_business
  end

  should 'NOT include non-participants' do
    non_participant = create_company(participant: false)
    results = SdgPioneer::EligibleBusinessesQuery.new.run
    assert_not_includes results, non_participant
  end

  should 'NOT include in-active participants' do
    inactive = create_company(active: false)
    results = SdgPioneer::EligibleBusinessesQuery.new.run
    assert_not_includes results, inactive
  end

  should 'filter by name' do
    first = create_company(name: 'first')
    second = create_company(name: 'second')

    results = SdgPioneer::EligibleBusinessesQuery.new(named: 'first').run
    assert_includes results, first
    assert_not_includes results, second
  end

  private

  def create_micro_enterprise(params = {})
    create(:organization, params.reverse_merge(
      active: true,
      participant: true,
      employees: 5
    )).tap do |o|
      assert_not_nil o.organization_type
      assert_equal OrganizationType.micro_enterprise, o.organization_type
    end
  end

  def create_sme(params = {})
    create(:organization, params.reverse_merge(
      active: true,
      participant: true,
      employees: 200
    )).tap do |o|
      assert_not_nil o.organization_type
      assert_equal OrganizationType.sme, o.organization_type
    end
  end

  def create_company(params = {})
    company_type = OrganizationType.company || create(:organization_type, {
      type_property: OrganizationType::BUSINESS,
      name: OrganizationType::FILTERS[:companies],
    })
    create(:organization, params.reverse_merge(
      active: true,
      participant: true,
      employees: 1000,
      organization_type: company_type
    )).tap do |o|
      assert_not_nil o.organization_type
      assert_equal OrganizationType.company, o.organization_type
    end
  end


end
