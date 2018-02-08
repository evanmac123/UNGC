require "test_helper"

class DueDiligenceTest < ActionDispatch::IntegrationTest
  setup do
    travel_to Time.zone.parse("2015-01-02 12:00:00")
  end

  teardown do
    travel_back
  end

  test "A full due diligence review" do
    # Given an organization with a participant manager
    organization = create(:business, :has_participant_manager, joined_on: Date.current)

    # And some contacts
    relationship_manager = organization.participant_manager
    requester = create(:staff_contact)
    integrity_team_member = create(:staff_contact, :integrity_team_member)
    integrity_manager = create(:staff_contact, :integrity_manager)

    # And an event
    event = create(:event)

    # And that a UNGC staff member is logged in
    login_as(requester)
    visit dashboard_path

    # When the Due Diligence menu button is clicked
    click_on "Due Diligence"
    all("a", text: "New due diligence review").first.click

    fill_in "Organization name", with: organization.name
    fill_in "Event title", with: event.title
    select "lead", from: "Level of engagement"
    fill_in "Individual subject", with: "Barack Obama"
    fill_in "review_additional_information", with: "..."
    click_on "Submit for Review"

    # Edit as requester
    within("tr", text: organization.name) do
      all(".preview").first.click
    end

    click_on "Process Review"

    fill_in "Organization name", with: organization.name
    fill_in "Event title", with: event.title
    select "sponsor", from: "Level of engagement"
    fill_in "Individual subject", with: "Individual McGee"
    fill_in "review_additional_information", with: "More info"
    click_on "Save"

    # Integrity reivew
    login_as(integrity_team_member)
    visit admin_due_diligence_reviews_path

    within("tr", text: organization.name) do
      all(".preview").first.click
    end

    # add a comment
    fill_in "Comment", with: "A new comment"
    check "Notify Participant Manager"
    click_on "Add comment"

    click_on "Process Review"

    fill_in "review_world_check_allegations", with: "World-Check", disabled: :all
    select "Yes", from: "Found on the UN Global Marketplace Ineligible Vendor Lists?"
    select "No", from: "Subject to UN or other government sanctions?"
    select "Yes", from: "Subject to dialog facilitation?"
    select "No", from: "Excluded by the Norwegian Government Pension Fund Global?"
    select "Yes", from: "Involved in the sale, manufacture or distribution of anti-personnel landmines or cluster bombs?"
    select "No", from: "Involved in production or sale of tobacco?"
    select "Yes", from: "Requires Local network input?"

    click_on "Save"

    select "Underperformer", from: "Overall ESG Score"
    select "Moderate", from: "Highest Controversy Level"
    select "71", from: "Peak RRI"
    select "20", from: "Current RRI"
    select "AAAA", from: "Rep Risk Severity of News"
    fill_in "Additional research", with: "Research'd"
    fill_in "Analysis comments", with: "These are my comments"

    click_on "Request local network input"

    within("tr", text: organization.name) do
      all(".preview").first.click
    end
    click_on "Process Review"

    fill_in "Local network input", with: "This is the network input"
    click_on "Save"
    click_on "Request Integrity Decision"

    login_as integrity_manager
    visit for_state_admin_due_diligence_reviews_path(state: :integrity_review)

    within("tr", text: organization.name) do
      all(".preview").first.click
    end

    click_on "Process Review"
    fill_in "Explanation", with: "My explanation..."

    click_on "With Reservation"

    within("tr", text: organization.name) do
      all(".preview").first.click
    end
    click_on "Process Review"

    fill_in "Engagement rationale", with: "My Rationale"
    fill_in "Approving Chief's name", with: "Approver McGee"
    select "not_available_but_interested", from: "Reason to Decline"
    click_on "Decline"

    within("tr", text: organization.name) do
      all(".preview").first.click
    end

    # Basic facts:
    assert_equal requester.name, basic_fact("Name of Requester")
    assert_equal "Sponsor", basic_fact("Level of Engagement")
    assert_equal "Individual McGee", basic_fact("Individual")
    assert_equal event.title, basic_fact("Event")
    assert_equal "More info", basic_fact("Additional Information")
    assert_equal relationship_manager.full_name_with_title, basic_fact("Relationship Manager")
    assert_equal organization.id.to_s, basic_fact("UNGC ID")
    assert_equal "2015-01-02", basic_fact("UNGC join date")
    assert_equal "None", basic_fact("Date of last submitted COP/ COE")
    assert_equal "Active", basic_fact("COP/ COE Status")
    assert_equal organization.name, basic_fact("Organization Name")
    assert_equal organization.country.name, basic_fact("Country")

    # Risk Assessment
    assert_equal "World-Check", find("#world_check_allegations").text
    assert_equal "Yes", risk_assessment("Found on the UN Global Marketplace Ineligible Vendor Lists")
    assert_equal "No", risk_assessment("Subject to UN or other government sanctions")
    assert_equal "Yes", risk_assessment("Subject to dialog facilitation")
    assert_equal "No", risk_assessment("Excluded by the Norwegian Government Pension Fund Global")
    assert_equal "Yes", risk_assessment("Involved in the sale, manufacture or distribution of anti-personnel landmines or cluster bombs")
    assert_equal "No", risk_assessment("Involved in production or sale of tobacco")
    assert_equal "Yes", risk_assessment("Requires Local Network Input?")
    assert_equal "No", risk_assessment("Delisted from the UNGC?")
    assert_equal "This is the network input", risk_assessment("Local Network input:")

    # Results from Sustainalytics
    assert_equal "underperformer", risk_assessment("ESG Score:", "span")
    assert_equal "moderate_controversy", risk_assessment("Highest Controversy:", "span")

    # Results from RepRisk
    assert_equal "20", risk_assessment("Current RRI", "span")
    assert_equal "71", risk_assessment("Peak RRI", "span")
    assert_equal "risk_severity_aaaa", risk_assessment("Severity of news", "span")

    analysis = find("#analysis").all("text()").last.text
    assert_equal "These are my comments", analysis

    # Integrity Decision
    assert_equal "Approved with integrity_reservation", integrity_decision("Decision:")
    assert_equal "My explanation...", integrity_decision("Explanation:")

    # Engagement Decision
    decision, approved_by, rationale, final_decision = all("#final-decision p").map(&:text)
    assert_equal "Decision: declined not_available_but_interested", decision
    assert_equal "Made by: Approver McGee", approved_by
    assert_equal "Decision: My Rationale", rationale
    assert_equal "Decision: Approved with integrity_reservation", final_decision

    assert page.has_content?("A new comment")

    # History
    events = all(".event-log li").map { |node| node.text.gsub(/ \(2015.+\)/, "") }
    expected_events = [
      "Review Requested by #{requester.name}",
      "Info Added by #{requester.name}",
      "Info Added by #{requester.name}",
      "Comment Created by #{integrity_team_member.name}",
      "Info Added by #{integrity_team_member.name}",
      "Info Added by #{integrity_team_member.name}",
      "Local Network Input Requested by #{integrity_team_member.name}",
      "Info Added by #{integrity_team_member.name}",
      "Info Added by #{integrity_team_member.name}",
      "Integrity Review Requested by #{integrity_team_member.name}",
      "Info Added by #{integrity_manager.name}",
      "Integrity Approval by #{integrity_manager.name}",
      "Info Added by #{integrity_manager.name}",

      # TODO: This should be integrity_manager see https://github.com/unglobalcompact/UNGC/issues/677
      "Declined by #{requester.name}",
    ]

    assert_equal expected_events, events, -> {
      diff = []
      expected_events.each_with_index do |expected, index|
        actual = events[index]
        if expected != actual
          diff << "Expected #{expected} to match #{actual}"
        end
      end
      diff.to_sentence
    }
  end

  private

  def basic_fact(text)
    within("#basic-facts") do
      find("li", text: text).all("text()", count: 2).last.text
    end
  end

  def risk_assessment(text, parent = "p")
    within("#risk-assessment") do
      find(parent, text: text).all("*", count: 2).last.text
    end
  end

  def integrity_decision(text)
    within("#engagement-recommendations") do
      find("p", text: text).all("text()", count: 2).last.text
    end
  end

end
