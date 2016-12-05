require 'test_helper'

class ParticipantApplicationsTest < ActiveSupport::TestCase

  test "renders output" do
    in_review = create(:business, state: Organization::STATE_IN_REVIEW)
    delay_review = create(:business, state: Organization::STATE_DELAY_REVIEW)
    approved = create(:business, state: Organization::STATE_APPROVED)
    rejected = create(:business, state: Organization::STATE_REJECTED)

    report = ParticipantApplications.new
    organizations = report.records

    assert_includes organizations, in_review
    assert_includes organizations, delay_review
    assert_not_includes organizations, approved
    assert_not_includes organizations, rejected
  end

end
