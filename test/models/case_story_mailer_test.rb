require 'test_helper'

class CaseStoryMailerTest < ActionMailer::TestCase
  def setup
    create_approved_case_story
  end

  test "in review mailer is sent" do
    response = CaseStoryMailer.in_review(@case_story).deliver
    assert_equal "text/html; charset=UTF-8", response.content_type
    assert_equal "Your Global Compact Case Story has been updated", response.subject
    assert_equal @organization_user.email, response.to.first
  end

  test "approved mailer is sent" do
    response = CaseStoryMailer.approved(@case_story).deliver
    assert_equal "text/html; charset=UTF-8", response.content_type
    assert_equal "Your Global Compact Case Story has been accepted", response.subject
    assert_equal @organization_user.email, response.to.first
  end

  test "rejected mailer is sent" do
    response = CaseStoryMailer.rejected(@case_story).deliver
    assert_equal "text/html; charset=UTF-8", response.content_type
    assert_equal "Global Compact Case Story Status", response.subject
    assert_equal @organization_user.email, response.to.first
  end
end