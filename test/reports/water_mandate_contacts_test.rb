require 'test_helper'

class WaterMandateContactsTest < ActiveSupport::TestCase

  test "water mandate contacts query passes" do
    create(:role, name: Role::FILTERS[:ceo_water_mandate])
    report = WaterMandateContacts.new
    assert_equal 0, report.records.count
  end
end
