# encoding: utf-8
require 'test_helper'

class EventTest < ActiveSupport::TestCase
  should_validate_presence_of :title, :message => "^Please provide a title"
  
  context "given an event with a strange title" do
    setup do
      @event1 = create_event :id => 1, :title => 'What? Is -this- å Tøtall¥! valid % name? Really!?'
      @event2 = create_event :title => 'What? Is -this- å Tøtall¥! valid % name? Really!?'
    end

    should "create an SEO-friendly permalink" do
      assert_equal "1-what-is-this-t-tall-valid-name-really", @event1.to_param
    end
    
    should "find event given a permalink" do
      assert_equal @event1, Event.find_by_permalink("1-what-is-this-t-tall-valid-name-really")
    end
  end
  
end
