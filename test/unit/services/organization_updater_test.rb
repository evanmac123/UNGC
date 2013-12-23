require 'test_helper'

class OrganizationUpdaterTest < ActiveSupport::TestCase
  context "update business organization" do
    setup do
      country = create_country
      sector = create_sector
      create_organization_and_user
      @organization.update_attributes(country: country, sector: sector)
      params = {
        organization: {
        },
        non_business_organization_registration: {
        }
      }
      @u = OrganizationUpdater.new(params)
    end

    should "update" do
      @organization.expects(:update_attributes).once.returns(true)
      @organization.registration.expects(:update_attributes).once.returns(true)

      # TODO investigate these
      @organization.expects(:set_replied_to).once
      @organization.expects(:set_last_modified_by).once
      # TODO test update_state
      @u.update(@organization, @organization_user)
    end
  end

  context "update non business organization" do
    setup do
      country = create_country
      create_non_business_organization_and_user
      @organization.update_attributes(country: country)
      params = {
        organization: {
        },
        non_business_organization_registration: {
          date: "2013-10-10",
          place: "here",
          authority: "un",
          mission_statement: "mission"
        }
      }
      @u = OrganizationUpdater.new(params)
    end

    should "update" do
      @u.update(@organization, @organization_user)
    end
  end

  context "create non participant (signatory) organization" do

    setup do
      country = create_country
      sector = create_sector
      params = {
        organization: {
          country_id: country.id,
          name: "test org",
          employees: 10,
          sector_id: sector.id,
          signings: {initiative_id: 7,
                     added_on: "2013-12-17"}
        },
        non_business_organization_registration: {
        }
      }
      @u = OrganizationUpdater.new(params)
    end

    should "save" do
      @u.create_signatory_organization
    end
  end
end
