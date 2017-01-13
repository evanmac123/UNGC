require 'test_helper'

class InitiativeTest < ActiveSupport::TestCase
  should have_many :signings
  should have_many(:signatories).through(:signings)
  should have_many :cop_questions

  test "Filtering initiatives by slug should find the initiative" do
    climate = Initiative.find(2)
    assert_same_elements [climate], Initiative.for_filter(:climate)
  end

end
