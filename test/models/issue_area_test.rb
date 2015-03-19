require 'test_helper'

class IssueAreaTest < ActiveSupport::TestCase

  should "require a name" do
    assert_raise ActiveRecord::StatementInvalid do
      create_issue_area name: nil
    end
  end

  should "have a name" do
    issue = create_issue_area name: 'foo'
    assert_equal 'foo', issue.name
  end

  should "have issue children" do
    issues = 2.times.map {create_issue}
    area = create_issue_area issues: issues

    assert_equal issues, area.issues
  end

end
