require 'test_helper'

class Redesign::EvenstListFormTest < ActiveSupport::TestCase

  should "filter events by country" do
    no_country = create_approved_event(country: nil)
    with_country = create_approved_event(country: country)

    results = search(countries: [country.id])

    assert_includes results, with_country
    assert_not_includes results, no_country
  end

  should "show events that span the current date" do
    today = Date.today
    started = today - 1.day
    ends = today + 2.days

    event = create_approved_event(starts_at: started, ends_at: ends)

    results = search

    assert_includes results, event
  end

  private

  def search(params = {})
    Redesign::EventsListForm.new(params).execute
  end

  def country
    @country ||= create_country
  end

  def create_approved_event(params = {})
    params.reverse_merge! starts_at: Date.today
    create_event(params).tap(&:approve!)
  end

end
