require 'test_helper'

class EventsListFormTest < ActiveSupport::TestCase
  context 'search with sustainable development goals in params' do
    setup do
      @sdgs = 2.times.collect { create(:sustainable_development_goal) }
      @params = { sustainable_development_goals: [@sdgs.first.id] }.deep_stringify_keys

      @search = EventsListForm.new @params
      @search.search_scope = FakeFacetResponse.with(:sustainable_development_goal_ids, @sdgs.map(&:id))
    end

    context '#sustainable_development_goal_filter#options' do
      should 'return all sustainable development goal options' do
        assert_equal @sdgs.map(&:id), @search.sustainable_development_goal_filter.options.map(&:id)
      end
    end

    context '#sustainable_development_goal_filter#options#select(&:selected?)' do
      should 'equal the selected sustainable development goal' do
        assert_equal [@sdgs.first.id], @search.sustainable_development_goal_filter.options.select(&:selected?).map(&:id)
      end
    end
  end

  def self.should_search_event(should_msg, starts_offset: 0, ends_offset: 0, today: Date.current, start_date: nil, end_date: nil)
    should should_msg do
      event = create_approved_event(
        starts_at: today + starts_offset.days,
        ends_at: today + ends_offset.days
      )

      EventsListForm.any_instance.stubs(execute: MockSearchResult.new(event))

      results = search(start_date: start_date, end_date: end_date)
      assert_includes results, event
    end
  end

  def self.should_search_event_start(should_msg, starts_offset = 0, ends_offset = 0)
    should_search_event(should_msg, starts_offset: starts_offset, ends_offset: ends_offset, start_date: Date.current)
  end

  def self.should_search_event_end(should_msg, starts_offset = 0, ends_offset = 0)
    should_search_event(should_msg, starts_offset: starts_offset, ends_offset: ends_offset, end_date: Date.current)
  end

  def self.should_search_event_start_end(should_msg, starts_offset = 0, ends_offset = 0)
    should_search_event(should_msg, starts_offset: starts_offset, ends_offset: ends_offset, start_date: Date.current, end_date: Date.current + 7.days)
  end

  context "search starts_at today" do
    should_search_event_start "show an event that starts today"
    should_search_event_start "show an event that spans across the current date", -1, +1
    should_search_event_start "show an event that spans the current date", -1
    should_search_event_start "show an event that starts in the future", +1, +3

    should "not show an event that ended yesterday" do
      event = create_approved_event(starts_at: Date.current - 2.days, ends_at: Date.current - 1.day)
      results = search(start_date: Date.current)
      assert_not_includes results, event
    end
  end

  context "search ends_at today" do
    should_search_event_end "show an event that starts today", 0, +1
    should_search_event_end "show an event that ends today", -1, 0
    should_search_event_end "show an event that spans the current date", -1, +1
    should_search_event_end "show an event that starts and ends in the past", -10, -5

    should "not show an event that starts tomorrow" do
      event = create_approved_event(starts_at: Date.current + 1.day, ends_at: Date.current + 3.days)
      results = search(end_date: Date.current)
      assert_not_includes results, event
    end
  end

  context "search starts_at today ends_at next week" do
    should_search_event_start_end "show an event that starts today", 0, 0
    should_search_event_start_end "show an event that ends tomorrow", 0, 1
    should_search_event_start_end "show an event that starts in 5 days and ends in 10", 5, 10
    should_search_event_start_end "show an event that starts in 3 days ago and ends in 5", 3, 5
    should_search_event_start_end "show an event that starts in 10 days ago and ends in 10", -10, 10

    should "not show an event that starts in 8 days" do
      event = create_approved_event(starts_at: Date.current + 8.days, ends_at: Date.current + 10.days)
      results = search(start_date: Date.current, end_date: Date.current + 7.days)
      assert_not_includes results, event
    end

    should "not show an event that ended 3 days ago" do
      event = create_approved_event(starts_at: Date.current - 8.days, ends_at: Date.current - 3.days)
      results = search(start_date: Date.current, end_date: Date.current + 7.days)
      assert_not_includes results, event
    end
  end

  private

  def search(params = {})
    EventsListForm.new(params).execute
  end

  def country
    @country ||= create_country
  end

  def create_approved_event(params = {})
    params.reverse_merge! starts_at: Date.current
    create(:event, params).tap(&:approve!)
  end

end
