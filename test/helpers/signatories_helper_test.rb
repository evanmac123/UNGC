require 'test_helper'

class SignatoriesHelperTest < ActionView::TestCase

  context "#signatories" do

    setup do
      @water_mandate = create_organization_for_initiative(:water_mandate)
      @climate   = create_organization_for_initiative(:climate)
    end

    should "filter when a filter is present" do
      sigs = signatories(:water_mandate).map(&:id)
      assert_contains sigs, @water_mandate.id
      refute sigs.include? @climate.id
    end

    should "not filter when filter_type is nil" do
      sigs = signatories.map(&:id)
      assert_contains sigs, @water_mandate.id
      assert_contains sigs, @climate.id
    end

  end

  def create_organization_for_initiative(initiative)
    create_organization_type
    o = create_organization
    i = Initiative.find_or_create_by!(id: Initiative::FILTER_TYPES[initiative])
    create_signing(initiative: i, organization: o)
    o
  end

end
