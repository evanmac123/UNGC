require 'test_helper'

class CaseStoryMailerTest < ActionMailer::TestCase
  def setup
    create_approved_case_story
  end
  
  test "in review mailer is sent" do
    response = CaseStoryMailer.deliver_in_review(@case_story)
    assert_equal "text/html", response.content_type
    assert_equal "Your Global Compact Case Story has been updated", response.subject
    assert_equal @organization_user.email, response.to.first
  end
  
  test "approved mailer is sent" do
    response = CaseStoryMailer.deliver_approved(@case_story)
    assert_equal "text/html", response.content_type
    assert_equal "Your Global Compact Case Story has been accepted", response.subject
    assert_equal @organization_user.email, response.to.first
  end
  
  test "rejected mailer is sent" do
    response = CaseStoryMailer.deliver_rejected(@case_story)
    assert_equal "text/html", response.content_type
    assert_equal "Global Compact Case Story Status", response.subject
    assert_equal @organization_user.email, response.to.first
  end
end
