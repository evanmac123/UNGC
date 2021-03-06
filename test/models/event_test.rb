# encoding: utf-8
require 'test_helper'

class EventTest < ActiveSupport::TestCase
  should validate_presence_of(:title).with_message("^Please provide a title")
  should belong_to :country

  context "given an event with a strange title" do
    setup do
      @event1 = create(:event, :id => 1, :title => 'What? Is -this- å Tøtall¥! valid % name? Really!?')
      @permalink = "1-what-is-this-a-totall-valid-name-really"
    end

    should "create an SEO-friendly permalink" do
      assert_equal @permalink, @event1.to_param
    end

    should "find event given a permalink" do
      assert_equal @event1, Event.find(@permalink)
    end
  end

  context "given a bunch of events" do
    setup do
      @today = Date.current
      starts = []
      5.times do
        starts_at = Time.mktime(@today.year, @today.month, rand(22)+1).to_date
        starts << starts_at
        ends_at   = starts_at + rand(4)
        create(:event, :starts_at => starts_at, :ends_at => ends_at, :approval => 'approved')
      end
      # not always later
      @other = ( (@today >> 2).year == @today.year ) ? @today >> 2 : @today << 2
      3.times do
        starts_at = Time.mktime(@other.year, @other.month, rand(22)+1).to_date
        starts << starts_at
        ends_at   = starts_at + rand(4)
        create(:event, :starts_at => starts_at, :ends_at => ends_at, :approval => 'approved')
      end
      @much_later = @today >> 14
      2.times do
        starts_at = Time.mktime(@much_later.year, @much_later.month, rand(22)+1).to_date
        starts << starts_at
        ends_at   = starts_at + rand(4)
        create(:event, :starts_at => starts_at, :ends_at => ends_at, :approval => 'approved')
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
      @event = create(:event)
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
      @event = build(:event)
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
        @event.country = build(:country, :name => 'country')
      end

      should "just have country for #full_location" do
        assert_equal 'country', @event.full_location
      end
    end

    context "with both location and country" do
      setup do
        @event.location = 'location'
        @event.country = build(:country, :name => 'country')
      end

      should "have 'location, country' for #full_location" do
        assert_equal 'location, country', @event.full_location
      end
    end

    context "with an invalid url" do
      setup do
        @event.call_to_action_1_url = "B3lBn76KKzCmOvp7EVomvPSEsiwsE3Bo0H1WhhyZK6Xq5Co2wL0W2x8swBpqOvJ1xiUcUhBNnDuIceTTNyJa5Yj1q4qinFYBpg4VXbYiOeehI9G2V3oJjhiBWqS05YSHQyZBAKGcnO7njnL9A1vq5kBNB01yBSCIZ3Lb4uDMfZScmv7KMgrsGixzq46aL3IJQW8MH37loOlMU4NPVWAh0HMlMUDlDQsf48T9895kbtZ7z8JDYs8WUXsyNlrwcTv1"
      end

      should "reject url" do
        assert_not @event.valid?
        assert_contains @event.errors.full_messages, "Call to action 1 url has a 255 character limit"
      end
    end

  end

end
