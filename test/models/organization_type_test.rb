require 'test_helper'

class OrganizationTypeTest < ActiveSupport::TestCase
  should validate_presence_of :name

  test "find Academics when filtering for :academia" do
    assert_same_names OrganizationType.where(name: "Academic"),
                      OrganizationType.for_filter(:academia)
  end

  test "find Public Sector Organizations when filtering for :public" do
    assert_same_names OrganizationType.where(name: "Public Sector Organization"),
                      OrganizationType.for_filter(:public)
  end

  test "find Companies when filtering for :companies" do
    assert_same_names OrganizationType.where(name: 'Company'),
                      OrganizationType.for_filter(:companies)
  end

  test "find SME when filtering for :sme" do
    assert_same_names OrganizationType.where(name: 'SME'),
                      OrganizationType.for_filter(:sme)
  end

  test "find SME and Companies when filtering for :companies and :sme" do
    assert_same_names OrganizationType.where(name: ['Company', 'SME']),
                      OrganizationType.for_filter(:companies, :sme)
  end

  test "find all organization types when using named scope for staff" do
    assert_same_names OrganizationType.all,
                      OrganizationType.staff_types
  end

  test "find company, sme, and micro enterprise when filtering for business" do
    # expected = OrganizationType.where(name: ["Company", "SME", "Micro Enterprise"])
    # TODO confirm that Micro should indeed be considered a business type and
    # then change the production data and the seed data to reflect
    assert_same_names OrganizationType.where(name: ["Company", "SME"]),
                      OrganizationType.business
  end

  test "find global and local types when filtering for labour" do
    assert_same_names OrganizationType.where(name: ["Labour Global", "Labour Local"]),
                      OrganizationType.labour
  end

  private

  def assert_same_names(expected, actual)
    assert_same_elements expected.pluck(:name), actual.pluck(:name)
  end

end
