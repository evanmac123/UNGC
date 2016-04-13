require 'test_helper'

class Searchable::SearchableEventTest < ActiveSupport::TestCase
  include SearchableTagTests
  include SearchableModelTests

  should "NOT index an unapproved event" do
    create(:event)
    assert_no_difference -> { Searchable.count } do
      Searchable.index_all
    end
  end

  should "index the title" do
    assert_equal event.title, searchable.title
  end

  should "index the description" do
    assert_includes searchable.content, event.description
  end

  should "indev overview description (without html tags)" do
    assert_includes searchable.content, 'a good event'
  end

  private

  def event
    @event ||= create(:event, {programme_description: '<b>a good event</b>'}).tap do |h|
      h.approve!
    end
  end
  alias_method :subject, :event

  def searchable
    @searchable ||= Searchable::SearchableEvent.new(event)
  end

end
