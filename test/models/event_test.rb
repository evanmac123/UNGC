# encoding: utf-8
require 'test_helper'

class EventTest < ActiveSupport::TestCase
  should validate_presence_of(:title).with_message("^Please provide a title")
  should belong_to :country

  context "given an event with a strange title" do
    setup do
      @event1 = create_event :id => 1, :title => 'What? Is -this- å Tøtall¥! valid % name? Really!?'
      @permalink = "1-#{Date.today.strftime('%m-%d-%Y')}"
    end

    should "create an SEO-friendly permalink" do
      assert_equal @permalink, @event1.to_param
    end

    should "find event given a permalink" do
      assert_equal @event1, Event.find_by_permalink(@permalink)
    end
  end

  context "given a bunch of events" do
    setup do
      @today = Date.today
      starts = []
      5.times do
        starts_at = Time.mktime(@today.year, @today.month, rand(22)+1).to_date
        starts << starts_at
        ends_at   = starts_at + rand(4)
        create_event :starts_at => starts_at, :ends_at => ends_at, :approval => 'approved'
      end
      # not always later
      @other = ( (@today >> 2).year == @today.year ) ? @today >> 2 : @today << 2
      3.times do
        starts_at = Time.mktime(@other.year, @other.month, rand(22)+1).to_date
        starts << starts_at
        ends_at   = starts_at + rand(4)
        create_event :starts_at => starts_at, :ends_at => ends_at, :approval => 'approved'
      end
      @much_later = @today >> 14
      2.times do
        starts_at = Time.mktime(@much_later.year, @much_later.month, rand(22)+1).to_date
        starts << starts_at
        ends_at   = starts_at + rand(4)
        create_event :starts_at => starts_at, :ends_at => ends_at, :approval => 'approved'
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
      assert_equal 3, Event.for_month_year(@other.month, @other.year).count
      assert_equal 3, Event.for_month_year(@other.month).count # even if we don't specify the year, it should assume
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
      @event = Event.new :title => FixtureReplacement.random_string
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
