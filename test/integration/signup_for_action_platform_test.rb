require "test_helper"

class SignupForActionPlatformTest < ActionDispatch::IntegrationTest

  test "participants can signup for action platforms" do
    # Given there are Platforms
    (1..9).map do |i|
      create(:action_platform_platform,
             name: "Platform #{i}",
             slug: "platform-#{i}")
    end

    # Given I'm logged in as a contact from a Participant business
    organization = create(:business, level_of_participation: :participant_level)
    contact = create(:contact_point,
                     state: "California",
                     postal_code: "90210",
                     organization: organization)
    login_as(contact)

    # When they visit the user's dashboard
    visit dashboard_path

    # And they click on the link
    click_on t("action_platform.labels.dashboard_tab")
    click_on t("action_platform.actions.signup")

    # Then they see the action platform signup form
    assert_equal new_admin_action_platform_subscription_path, current_path

    # When they choose 2 platforms
    within "*[role=platform-2]" do
      check "Platform 2"
      select contact.name
    end

    within "*[role=platform-4]" do
      check "Platform 4"
      select contact.name
    end

    # And they accept that they must act with integrity
    check t("action_platform.accepts_terms_of_use")

    # And they update the financial contact's name
    fill_in "Email", with: "new-email@example.com"

    # And they confirm their financial contact
    check t("action_platform.confirm_financial_contact")

    # And they update their revenue
    fill_in t("action_platform.revenue_label"), with: "$3,200,000"

    # And click submit
    click_on t("action_platform.actions.submit")

    # Then they are told that they have been accepted into those 2 platforms
    assert_match %r(/admin/action_platform/subscriptions/\d+), current_path, "failed to submit the form"
    assert page.has_content?(t("action_platform.confirm_subscription")), "missing confirmation message"

    # And that they will be invoiced
    assert page.has_content?(t("action_platform.you_will_be_invoiced")), "missing invoice notice"

    # And an event was fired
    stream = organization.event_stream_name
    event = event_store.read_stream_events_forward(stream).first

    assert_not_nil event
    assert_equal organization.id, event.data.fetch(:organization_id)
    assert_not_nil event.data.fetch(:order_id)
    assert_equal 2, event.data.fetch(:platform_ids).length
  end

  test "non-participants cannot signup for action platforms" do
    # Given I'm logged in as a contact from a signatory business
    organization = create(:business, level_of_participation: :signatory_level)
    contact = create(:contact_point,
                     state: "California",
                     postal_code: "90210",
                     organization: organization)
    login_as(contact)

    # When they visit the user's dashboard
    visit dashboard_path

    # And they click on the link
    click_on t("action_platform.labels.dashboard_tab")
    click_on t("action_platform.actions.signup")

    # Then they see the action platform signup form
    assert_equal dashboard_path, current_path
  end

end
