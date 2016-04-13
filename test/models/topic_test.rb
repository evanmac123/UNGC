require 'test_helper'

class TopicTest < ActiveSupport::TestCase

  should "require a name" do
    assert_raise ActiveRecord::StatementInvalid do
      topic = build(:topic, name: nil)
      topic.save(validate: false)
    end
  end

  should "have a name" do
    topic = create(:topic, name: 'foo')
    assert_equal 'foo', topic.name
  end

  should "have a topic parent" do
    parent = create(:topic)
    topic = create(:topic, parent: parent)

    assert_equal parent, topic.parent
  end

  should "have topic children" do
    children = 3.times.map { create(:topic) }
    topic = create(:topic, children: children)

    assert_equal children, topic.children
  end

end
