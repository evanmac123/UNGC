require 'test_helper'

class InitiativeTest < ActiveSupport::TestCase
  should have_many :signings
  should have_many(:signatories).through(:signings)
  should have_many :cop_questions

  # :climate => id(2)
  context "filtering initiatives for a type" do
    setup do
      @climate = create(:initiative, :id => 2, :name => 'Climate Change')
    end

    should "find the climate change initiative" do
      assert_same_elements [@climate], Initiative.for_filter(:climate)
    end
  end

end
