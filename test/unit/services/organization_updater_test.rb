require 'test_helper'

class OrganizationUpdaterTest < ActiveSupport::TestCase
  context "update business organization" do
    setup do

      @organization = OpenStruct.new(
        registration: BusinessOrganizationRegistration.new,
        error_message: 'test error',
        state: Organization::STATE_IN_REVIEW
      )
      @contact = OpenStruct.new
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
      @u.update(@organization, @contact)
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
      assert @u.create_signatory_organization
    end
  end
end
