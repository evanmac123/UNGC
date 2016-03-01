require 'test_helper'

class ExpressCopSubmissionTest < ActionDispatch::IntegrationTest
  setup do
    create_organization_type_sme
  end

  test "Submitting a Express COP" do
    # Given I'm signed in as a contact from an SME
    o = create_organization(employees:100, state:'approved')
    c = create_contact(organization: o)
    login_as(c)

    visit '/admin/cops/introduction'
    puts page.html
    click_link 'Submit a Express COP'

    # When I fill out the Express COP form
    # /admin/cops/introduction
    # Then I should see a success message
    #
  end

end

