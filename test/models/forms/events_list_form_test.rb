# require 'test_helper'


# class Redesign::EvenstListFormTest < ActiveSupport::TestCase

#   def self.should_search_event(should_msg, starts_offset: 0, ends_offset: 0, today: Date.today, start_date: nil, end_date: nil)
#     should should_msg do
#       event = create_approved_event(
#         starts_at: today + starts_offset.days,
#         ends_at: today + ends_offset.days
#       )
#       results = search(start_date: start_date, end_date: end_date)
#       assert_includes results, event
#     end
#   end

#   def self.should_search_event_start(should_msg, starts_offset = 0, ends_offset = 0)
#     should_search_event(should_msg, starts_offset: starts_offset, ends_offset: ends_offset, start_date: Date.today)
#   end

#   def self.should_search_event_end(should_msg, starts_offset = 0, ends_offset = 0)
#     should_search_event(should_msg, starts_offset: starts_offset, ends_offset: ends_offset, end_date: Date.today)
#   end

#   def self.should_search_event_start_end(should_msg, starts_offset = 0, ends_offset = 0)
#     should_search_event(should_msg, starts_offset: starts_offset, ends_offset: ends_offset, start_date: Date.today, end_date: Date.today + 7.days)
#   end

#   context "search starts_at today" do

#     should "not show an event that ended yesterday" do
#       event = create_approved_event(starts_at: Date.today - 2.days, ends_at: Date.today - 1.day)

#       results = search(start_date: Date.today)
#       assert_not_includes results, event
#     end

#     should_search_event_start "show an event that starts today"
#     should_search_event_start "show an event that spans across the current date", -1, +1
#     should_search_event_start "show an event that spans the current date", -1
#     should_search_event_start "show an event that starts in the future", +1, +3

#   end

#   context "search ends_at today" do

#     should_search_event_end "show an event that starts today", 0, +1
#     should_search_event_end "show an event that ends today", -1, 0
#     should_search_event_end "show an event that spans the current date", -1, +1
#     should_search_event_end "show an event that starts and ends in the past", -10, -5

#     should "not show an event that starts tomorrow" do
#       event = create_approved_event(starts_at: Date.today + 1.day, ends_at: Date.today + 3.days)
#       results = search(end_date: Date.today)
#       assert_not_includes results, event
#     end

#   end

#   context "search starts_at today ends_at next week" do

#     should_search_event_start_end "show an event that starts today", 0, 0
#     should_search_event_start_end "show an event that ends tomorrow", 0, 1
#     should_search_event_start_end "show an event that starts in 5 days and ends in 10", 5, 10
#     should_search_event_start_end "show an event that starts in 3 days ago and ends in 5", 3, 5
#     should_search_event_start_end "show an event that starts in 10 days ago and ends in 10", -10, 10

#     should "not show an event that starts in 8 days" do
#       event = create_approved_event(starts_at: Date.today + 8.days, ends_at: Date.today + 10.days)
#       results = search(start_date: Date.today, end_date: Date.today + 7.days)
#       assert_not_includes results, event
#     end

#     should "not show an event that ended 3 days ago" do
#       event = create_approved_event(starts_at: Date.today - 8.days, ends_at: Date.today - 3.days)
#       results = search(start_date: Date.today, end_date: Date.today + 7.days)
#       assert_not_includes results, event
#     end

#   end

#   private

#   def search(params = {})
#     Redesign::EventsListForm.new(params).execute
#   end

#   def country
#     @country ||= create_country
#   end

#   def create_approved_event(params = {})
#     params.reverse_merge! starts_at: Date.today
#     create_event(params).tap(&:approve!)
#   end

# end
