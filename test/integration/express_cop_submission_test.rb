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
    click_link 'Submit an Express Template COP here'

    # When I fill out the Express COP form
    choose 'express_cop_endorses_ten_principles_false'
    choose 'express_cop_covers_issue_areas_false'
    choose 'express_cop_measures_outcomes_true'
    click_on 'Submit'

    # Then I should see a success message
    puts page.html
    assert page.has_content? I18n.t('notice.cop_published')
  end

end

