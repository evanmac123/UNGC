require "test_helper"
require "sidekiq/testing"

class DueDiligenceTest < ActionDispatch::IntegrationTest
  setup do
    Sidekiq::Testing.inline!
  end

  test "A full due diligence review" do
    skip 'to be completed'

    # Given an organization
    organization = create(:business, :has_participant_manager)

    # And I am logged in as a staff member
    staff = create_staff_user
    login_as(staff)

    # When the requester visits the due diligience index page
    index_page = DueDiligence::Review::Index.new
    pending_review_page = DueDiligence::Review::InReview.new

    index_page.visit(index_page.path)
    page.assert_selector("h2", text: pending_review_page.title)

    pages = [["In Review", DueDiligence::Review::InReview.new],
             ["Local Network", DueDiligence::Review::LocalNetworkReview.new],
             ["Integrity Decision", DueDiligence::Review::IntegrityReview.new],
             ["Engagement Decision", DueDiligence::Review::EngagementDecision.new],
             ["All Reviews", DueDiligence::Review::AllReviews.new]]
    pages.each do |link, page_object|
      pending_review_page.click_on link
      pending_review_page.transition_to page_object
      page.assert_selector("h2", text: page_object.title)
    end

    # And clicks on New Review
    pending_review = pending_review_page.new_review

    # And supplies the organization's name and level of engagement
    pending_review.fill_in_organization_name(organization.name)
    pending_review.select_level_of_engagement("speaker")
    pending_review.fill_in_additional_information("Leaders Summit")

    review_page = pending_review.submit

    # Then a review should be created with the name of the organization
    assert_equal organization.name, review_page.organization_name

    # And it should be pending
    assert_in_state(review_page, "in_review")

    # And have the reviewer"s name
    assert page.has_content? Regexp.new(staff.name)

    # When the reviewer adds a comment
    comment_body = "This review needs a integrity recommendation."
    review_page.add_comment(comment_body)
    assert review_page.email_sent_to_legal?, "Expected email to be sent to integrity Team"
    assert review_page.email_sent_to_participant_manager?, "Expected email to be sent to Participant Manager"

    # CommentCreated event was fired
    event = event_store.read_all_streams_forward.last
    assert_not_nil event
    assert event.is_a? DueDiligence::Events::CommentCreated
    assert_equal comment_body, event.data.fetch(:body)
    assert_not_nil event.data.fetch(:contact_id)
    assert_equal staff.id, event.data.fetch(:contact_id)

    # Then they should see it in the timeline
    assert review_page.has_comment?(comment_body), "comment body not found"

    # TODO
    # When the reviewer adds a document
    # review_page.add_document("untitled.pdf")
    # Then they should see a link to it in the timeline

    # When a member of the RM team logs in
    # And visits the Due Diligence reviews
    pending_review_page.visit

    # Then they should see the review in the list
    # When they click the review
    review_page = pending_review_page.click_on_organization(organization.name)

    # When the reviewer adds info to the risk assessment
    risk_assessment_page = review_page.click_risk_assessment
    risk_assessment_page.select("4", from: "Overall ESG Score")
    risk_assessment_page.check("Involved in production or sale of tobacco")
    risk_assessment_page.click_on("Update")

    # Then the Review is now "in review"
    assert_in_state(review_page, "in_review")

    # # Then they should see the changes
    assert_equal "4", review_page.overall_esg_score
    assert_equal "true", review_page.involved_in_tobacco?

    # When the reviewer adds Highest Controversy Level
    # And checks "excluded from norewgian pension fund"
    # And clicks "Update"
    risk_assessment_page = review_page.click_risk_assessment
    risk_assessment_page.choose("3")
    risk_assessment_page.check("Excluded by the Norwegian Government Pension Fund")
    risk_assessment_page.click_on("Update")

    # Then they should see the changes
    assert_equal "3", review_page.highest_controversy_level
    assert_equal "true", review_page.excluded_by_the_norwegian_fund?

    # When the reviewer requests integrity recommendations
    # Then the review moves to "integrity review"
    risk_assessment_page = review_page.click_risk_assessment
    risk_assessment_page.click_on("Request integrity recommendations")
    assert_in_state(review_page, "integrity_review")

    # When the review adds a peak rep risk and a World-Check allegation
    risk_assessment_page = review_page.click_risk_assessment
    risk_assessment_page.select("2", from: "Peak RRI")
    risk_assessment_page.fill_in_world_check_allegations(with: world_check_text)
    risk_assessment_page.click_on("Update")

    assert_match(/man bun/, review_page.world_check_allegations)
    assert_equal "2", review_page.peak_rri

    # And clicks the "Request integrity Recommendations" button
    # Then the Review moves back to "integrity review"
    risk_assessment_page = review_page.click_risk_assessment
    risk_assessment_page.click_on("Request integrity recommendations")
    assert_in_state(review_page, "integrity_review")

    # When the integrity Team is satisfied
    # And enters their recommendations
    # And checks "Final decision"
    # Then the review enters the "Final decision"
    integrity_page = review_page.click_integrity_recommendations
    integrity_page.fill_in("Recommendation", with: "integrity recommendation")
    integrity_page.fill_in("Explanation", with: "")
    integrity_page.click_on("Final decision")
    assert_in_state(review_page, "engagement_decision")

    # When the reviewer receives a final decision out of band,
    # And the reviewer enters any notes given
    # And the approving Chief's name
    # And click "Approve"
    # Then the Review moves to "Engaged"
    decision_page = review_page.click_final_decision
    decision_page.fill_in("Final decision", with: "LGTM ++")
    decision_page.fill_in("Approving Chief's name", with: "Alice Munroe")
    decision_page.click_on("Approve")
    assert_in_state(review_page, "engaged")
  end

  private

  def assert_in_state(page, state)
    assert_equal state, page.state
  end

  def world_check_text
    <<-LONG
    Master cleanse hell of godard cold-pressed, snackwave selfies thundercats coloring book franzen. Jianbing meh pork belly chillwave direct trade, pinterest chia cronut hella yr jean shorts next level. Lomo chambray slow-carb skateboard twee fixie, pabst cred pok pok. Disrupt fam vaporware viral. Etsy lyft prism kombucha celiac. Cronut kogi health goth vape, pour-over air plant kickstarter echo park tofu cornhole leggings roof party skateboard ennui. Messenger bag activated charcoal pug locavore, jianbing umami blog hammock coloring book.

    Tattooed meditation shoreditch tumblr dreamcatcher synth. Kitsch vaporware wolf, bespoke edison bulb forage XOXO. Retro tbh raw denim cray everyday carry squid bespoke vexillologist. Pug lumbersexual waistcoat, try-hard venmo polaroid cardigan everyday carry taxidermy hella put a bird on it vape deep v shoreditch marfa. Thundercats fam wayfarers four dollar toast. 90's hammock whatever williamsburg four dollar toast flannel. Austin coloring book occupy taxidermy farm-to-table, chartreuse pickled put a bird on it waistcoat kogi truffaut four dollar toast retro poke.

    Meditation lyft blog artisan, chambray next level umami cray edison bulb four loko etsy 90's irony photo booth fam. Ennui hammock dreamcatcher sartorial. Tattooed normcore hammock small batch. Cornhole vegan four dollar toast, keffiyeh fashion axe bespoke kale chips umami woke selvage poutine. Shabby chic enamel pin YOLO raw denim. Ethical migas 8-bit, chicharrones quinoa tbh normcore kale chips meggings meh. Chillwave skateboard hammock affogato.

    Knausgaard gastropub sartorial echo park. Gluten-free man bun PBR&B, yuccie listicle marfa vegan crucifix chia scenester green juice echo park chambray. Mlkshk waistcoat fap normcore flexitarian, dreamcatcher twee vice roof party coloring book 90's echo park gastropub. Mustache slow-carb prism etsy, vaporware +1 hot chicken bushwick. Neutra mustache wayfarers, gochujang pinterest skateboard copper mug. Mlkshk irony snackwave, seitan shoreditch vape meh. Lo-fi deep v pug, hell of ennui slow-carb gochujang kitsch vegan.
    LONG
  end

end
