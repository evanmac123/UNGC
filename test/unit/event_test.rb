# encoding: utf-8
require 'test_helper'

class EventTest < ActiveSupport::TestCase
  should_validate_presence_of :title, :message => "^Please provide a title"
  should_belong_to :country
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
      starts = []
      5.times do
        starts_on = Time.mktime(@today.year, @today.month, rand(22)+1).to_date
        starts << starts_on
        ends_on   = starts_on + rand(4)
        create_event :starts_on => starts_on, :ends_on => ends_on, :approval => 'approved'  
      end
      @later = @today >> 2
      3.times do
        starts_on = Time.mktime(@later.year, @later.month, rand(22)+1).to_date
        starts << starts_on
        ends_on   = starts_on + rand(4)
        create_event :starts_on => starts_on, :ends_on => ends_on, :approval => 'approved'  
      end
      @much_later = @today >> 14
      2.times do
        starts_on = Time.mktime(@much_later.year, @much_later.month, rand(22)+1).to_date
        starts << starts_on
        ends_on   = starts_on + rand(4)
        create_event :starts_on => starts_on, :ends_on => ends_on, :approval => 'approved'  
      end
      # puts "??"
      # puts starts.join(', ')
      # puts "??"
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
      assert_equal 0, Event.for_month_year((@today >> 1).month, @today.year).count, "Find no events for next month"
      assert_equal 0, Event.for_month_year(@today.month, @today.year + 1).count, "Find no events for next year"
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
  
  context "given some Principle Areas" do
    setup do
      @p1 = create_principle_area
      @p2 = create_principle_area
      @p3 = create_principle_area
      @event = new_event
      @event.selected_issues = [@p1.id, @p2.id]
      @event.save
      @event.reload
    end

    should "link event and areas on save" do
      assert_same_elements [@p1, @p2], @event.issues
    end
    
    context "and selected issues are changed" do
      setup do
        @event.selected_issues = [@p2.id, @p3.id]
        @event.save
        @event.reload
      end

      should "change event areas" do
        assert_same_elements [@p2, @p3], @event.issues
      end
    end
    
  end
  
  context "given an event" do
    setup do
      @event = new_event
    end

    context "with just a location" do
      setup do
        @event.location = 'location'
      end

      should "just have location for #full_location" do
        assert_equal 'location', @event.full_location
      end
    end

    context "with just a country" do
      setup do
        @event.country = new_country(:name => 'country')
      end

      should "just have country for #full_location" do
        assert_equal 'country', @event.full_location
      end
    end
    
    context "with both location and country" do
      setup do
        @event.location = 'location'
        @event.country = new_country(:name => 'country')
      end

      should "have 'location, country' for #full_location" do
        assert_equal 'location, country', @event.full_location
      end
    end
    
  end
  
end
