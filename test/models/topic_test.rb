require 'test_helper'

class TopicTest < ActiveSupport::TestCase

  should "require a name" do
    assert_raise ActiveRecord::StatementInvalid do
      create_topic name: nil
    end
  end

  should "have a name" do
    topic = create_topic name: 'foo'
    assert_equal 'foo', topic.name
  end

  should "have a topic parent" do
    parent = create_topic
    topic = create_topic parent: parent

    assert_equal parent, topic.parent
  end

  should "have topic children" do
    children = 3.times.map {create_topic}
    topic = create_topic children: children

    assert_equal children, topic.children
  end

end
