require 'test_helper'

class Admin::ExpressCopsControllerTest < ActionController::TestCase

  should 'reject non-SME organizations' do
    create(:sme_type)
    organization = create(:business, employees: 1000)

    contact = create(:contact_point, organization: organization)
    sign_in(contact)

    assert organization.organization_type != OrganizationType.sme

    get :new, organization_id: organization
    assert_redirected_to cop_introduction_url
  end

end
