require 'test_helper'

class OrganizationUpdaterTest < ActiveSupport::TestCase
  context "update business organization" do
    setup do

      organization = OpenStruct.new(
        registration: BusinessOrganizationRegistration.new,
        error_message: 'test error'
      )
      contact = OpenStruct.new
      params = {
        organization: {
        },
        non_business_organization_registration: {
        }
      }

      @u = OrganizationUpdater.new(organization, contact, params)
    end

    should "return the error messages" do
      msg = @u.error_message
      assert_equal msg, 'test error'
    end

    should "update" do
      @u.organization.expects(:update_attributes).once.returns(true)
      @u.organization.registration.expects(:update_attributes).once.returns(true)

      # TODO investigate these
      @u.organization.expects(:set_replied_to).once
      @u.organization.expects(:set_last_modified_by).once
      # TODO test update_state
      @u.update
    end
  end
end
