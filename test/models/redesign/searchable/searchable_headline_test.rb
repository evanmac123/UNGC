require 'test_helper'

class Redesign::Searchable::SearchableHeadlineTest < ActiveSupport::TestCase
  include SearchableTagTests
  include SearchableModelTests

  should "NOT index an unapproved headline" do
    create_headline
    assert_no_difference -> { Redesign::Searchable.count } do
      Redesign::Searchable.index_all
    end
  end

  private

  def headline
    @headline ||= create_headline.tap do |h|
      h.approve!
    end
  end
  alias_method :subject, :headline

end
