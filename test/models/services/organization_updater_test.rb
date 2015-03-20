require 'test_helper'

class OrganizationUpdaterTest < ActiveSupport::TestCase
  context "update business organization" do
    setup do
      country = create_country
      sector = create_sector
      create_organization_and_user
      @organization.update_attributes(country: country, sector: sector)
      @u = OrganizationUpdater.new({}, {})
    end

    should "update" do
      @organization.expects(:save).once.returns(true)
      @organization.registration.expects(:save).once.returns(true)

      # TODO investigate these
      @organization.expects(:set_replied_to).once
      @organization.expects(:set_last_modified_by).once

      @u.update(@organization, @organization_user)
    end
  end

  context "update non business organization" do
    setup do
      country = create_country
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

  context "create non participant (signatory) organization" do

    setup do
      country = create_country
      sector = create_sector
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
      @u = OrganizationUpdater.new(organization_params, {})
    end

    should "save" do
      @u.create_signatory_organization
    end
  end
end
