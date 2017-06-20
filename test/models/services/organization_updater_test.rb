require 'test_helper'

class OrganizationUpdaterTest < ActiveSupport::TestCase
  context "update business organization" do
    setup do
      country = create(:country)
      sector = create(:sector)
      create_organization_and_user
      @organization.update_attributes(country: country, sector: sector)
      @u = OrganizationUpdater.new({}, {})
    end

    should "update" do
      @organization.expects(:save).once.returns(true)
      @organization.registration.expects(:save).once.returns(true)

      # TODO investigate these
      @organization.expects(:set_replied_to).once
      @organization.expects(:last_modified_by_id=).
        with(@organization_user.id).
        once

      assert @u.update(@organization, @organization_user)
    end
  end

  context "update non business organization" do
    setup do
      country = create(:country)
      create_non_business_organization_and_user
      @organization.update_attributes(country: country)
      registration_params = {
        date: "2013-10-10",
        place: "here",
        authority: "un",
        mission_statement: "mission"
      }
      @u = OrganizationUpdater.new({}, registration_params)
    end

    should "update" do
      @u.update(@organization, @organization_user)
    end
  end

  should "create non participant (signatory) organization" do
    country = create(:country)
    sector = Sector.not_applicable

    organization_params = {
      country_id: country.id,
      name: "test org",
      employees: 10,
      sector_id: sector.id,
      signings: {
        initiative_id: 7,
        added_on: "2013-12-17"
      }
    }

    updater = OrganizationUpdater.new(organization_params, {})
    success = updater.create_signatory_organization
    organization = updater.organization

    assert success
    assert_not_nil organization
    assert_equal OrganizationType.signatory, organization.organization_type
    assert_equal 1, organization.signings.count
  end
end
