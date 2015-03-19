require 'test_helper'

class IssueTest < ActiveSupport::TestCase

  should "require a name" do
    assert_raise ActiveRecord::StatementInvalid do
      create_issue name: nil
    end
  end

  should "have a name" do
    issue = create_issue name: 'foo'
    assert_equal 'foo', issue.name
  end

  should "have an issue area" do
    area = create_issue_area
    issue = create_issue issue_area: area
    assert_equal area, issue.issue_area
  end

end
