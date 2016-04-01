require 'test_helper'

class Admin::ExpressCopsControllerTest < ActionController::TestCase

  should 'reject non-SME organizations' do
    create_organization_type_sme
    organization = create_business

    contact = create_contact(organization: organization)
    sign_in(contact)

    assert organization.organization_type != OrganizationType.sme

    get :new, organization_id: organization
    assert_redirected_to cop_introduction_url
  end

end
