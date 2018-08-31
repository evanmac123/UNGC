require "test_helper"

class OrganizationCanEditSocialNetworksTest < ActionDispatch::IntegrationTest

  test "defining social networks" do
    # Given an organization with twitter and instagram handles
    organization = create(:organization,
      listing_status: create(:listing_status),
    )

    # When staff login and edit
    login_as create(:staff_contact)
    visit edit_admin_organization_path(organization)

    # And they add a facebook handle
    select "Twitter", from: "organization[social_network_handles_attributes][0][network_code]"
    fill_in "organization[social_network_handles_attributes][0][handle]", with: "zuck"

    # And they click save
    click_on "Save changes"

    # Then we see that facebook has been added, instagram remains and twitter has been removed
    networks = organization.social_network_handles.order(:created_at).pluck(:network_code)
    assert_equal %w(twitter), networks
  end

end
