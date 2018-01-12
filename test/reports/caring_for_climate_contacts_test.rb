require 'test_helper'

class CaringForClimateContactsTest < ActiveSupport::TestCase

  test "caring for climate contacts query passes" do
    create(:role, name: Role::FILTERS[:caring_for_climate])
    report = CaringForClimateContacts.new
    assert_equal 0, report.records.count
  end
end
