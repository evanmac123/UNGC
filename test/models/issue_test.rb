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
    area = create_issue
    issue = create_issue parent: area
    assert_equal area, issue.parent
  end

  should "have issue children" do
    issues = 2.times.map {create_issue}
    area = create_issue children: issues

    assert_equal issues, area.children
  end

end
