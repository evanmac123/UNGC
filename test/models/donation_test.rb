require 'test_helper'

class DonationTest < ActiveSupport::TestCase
  include ActionView::Helpers::NumberHelper

  test "Donation can round-trip amounts" do
    donation = Donation.new(amount: "$12,345.67")
    assert_equal 1234567, donation.amount.cents
    assert_equal "$12,345.67", donation.amount.format
  end

end
