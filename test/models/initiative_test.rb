require 'test_helper'

class InitiativeTest < ActiveSupport::TestCase
  should have_many :signings
  should have_many(:signatories).through(:signings)
  should have_many :cop_questions

  should validate_length_of(:sitemap_path).is_at_most(255)

  test "Filtering initiatives by slug should find the initiative" do
    climate = Initiative.find_by_name("Caring For Climate")
    assert_same_elements [climate], Initiative.for_filter(:climate)
  end

end
