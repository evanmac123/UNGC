require 'test_helper'

class Api::V1::OrganizationsTest < ActionDispatch::IntegrationTest

  test "/api/v1/organizations" do
    # Given 2 approved participants
    # When i visit /api/v1/organizations
    # I should see a list of organizations

    visit "/api/v1/organzations.json"
    assert_equal 200, page.status_code
  end

end
