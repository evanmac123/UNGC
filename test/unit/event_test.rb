# encoding: utf-8
require 'test_helper'

class EventTest < ActiveSupport::TestCase
  should_validate_presence_of :title, :message => "^Please provide a title"
  should_belong_to :country
  should_belong_to :created_by
  should_belong_to :updated_by
  should_have_many :attachments
  
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
  
  context "given a bunch of events" do
    setup do
      @today = Date.today
      5.times do
        starts_on = Time.mktime(@today.year, @today.month, rand(25)+1).to_date
        ends_on   = starts_on + rand(4)
        create_event :starts_on => starts_on, :ends_on => ends_on, :approval => 'approved'  
      end
      @later = @today >> 2
      3.times do
        starts_on = Time.mktime(@later.year, @later.month, rand(25)+1).to_date
        ends_on   = starts_on + rand(4)
        create_event :starts_on => starts_on, :ends_on => ends_on, :approval => 'approved'  
      end
      @much_later = @today >> 14
      2.times do
        starts_on = Time.mktime(@much_later.year, @much_later.month, rand(25)).to_date
        ends_on   = starts_on + rand(4)
        create_event :starts_on => starts_on, :ends_on => ends_on, :approval => 'approved'  
      end
    end

    should "find events for this month" do
      assert_equal 5, Event.for_month_year(@today.month, @today.year).count
      assert_equal 5, Event.for_month_year(@today.month).count
      assert_equal 5, Event.for_month_year().count # even if we don't specify today, it should assume
    end
    
    should "find events for later" do
      assert_equal 3, Event.for_month_year(@later.month, @later.year).count
      assert_equal 3, Event.for_month_year(@later.month).count # even if we don't specify the year, it should assume
    end
    
    should "find events for much later" do
      assert_equal 2, Event.for_month_year(@much_later.month, @much_later.year).count
    end
    
    should "find no events for months and years with no events" do
      assert_equal 0, Event.for_month_year((@today >> 1).month, @today.year).count
      assert_equal 0, Event.for_month_year(@today.month, @today.year + 1).count
    end
  end
  
  context "given a new event" do
    setup do
      @event = Event.new :title => String.random
      assert @event.save
    end

    should "start 'pending' approval" do
      assert @event.pending?
    end
    
    context "and it is approved" do
      setup do
        assert @event.approve!
      end

      should "should be in 'approved' approval" do
        assert @event.approved?
      end
    end
    
  end
  
  
end
