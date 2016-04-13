require 'test_helper'

class IssueTest < ActiveSupport::TestCase

  should "require a name" do
    assert_raise ActiveRecord::StatementInvalid do
      issue = build(:issue, name: nil)
      issue.save(validate: false)
    end
  end

  should "have a name" do
    issue = create(:issue, name: 'foo')
    assert_equal 'foo', issue.name
  end

  should "have an issue area" do
    area = create(:issue)
    issue = create(:issue, parent: area)
    assert_equal area, issue.parent
  end

  should "have issue children" do
    issues = 2.times.map { create(:issue) }
    area = create(:issue, children: issues)

    assert_equal issues, area.children
  end

end
