require 'test_helper'

class OrganizationTypeTest < ActiveSupport::TestCase
  should validate_presence_of :name

  context "filtering by type" do
    setup do
      @academia      = create_organization_type(:name => 'Academic', :type_property => 1 )
      @public        = create_organization_type(:name => 'Public Sector Organization', :type_property => 1)
      @companies     = create_organization_type(:name => 'Company', :type_property => 2)
      @sme           = create_organization_type(:name => 'SME', :type_property => 2)
      @micro         = create_organization_type(:name => 'Micro Enterprise', :type_property => 2)
      @labour_global = create_organization_type(:name => 'Labour Global', :type_property => 1)
      @labour_local  = create_organization_type(:name => 'Labour Local', :type_property => 1)
    end

    should "find Academics when filtering for :academia" do
      assert_same_elements [@academia], OrganizationType.for_filter(:academia)
    end

    should "find Public Sector Organizations when filtering for :public" do
      assert_same_elements [@public], OrganizationType.for_filter(:public)
    end

    should "find Companies when filtering for :companies" do
      assert_same_elements [@companies], OrganizationType.for_filter(:companies)
    end

    should "find SME when filtering for :sme" do
      assert_same_elements [@sme], OrganizationType.for_filter(:sme)
    end

    should "find SME and Companies when filtering for :companies and :sme" do
      assert_same_elements [@companies, @sme], OrganizationType.for_filter(:companies, :sme)
    end

    should "find all organization types when using named scope for staff" do
      assert_same_elements [@academia, @public, @companies, @sme, @micro, @labour_global, @labour_local], OrganizationType.staff_types
    end

    should "find company, sme, and micro enterprise when filtering for business" do
      assert_same_elements [@companies, @sme, @micro], OrganizationType.business
    end

    should "find global and local types when filtering for labour" do
      assert_same_elements [@labour_global, @labour_local], OrganizationType.labour
    end

  end

end
