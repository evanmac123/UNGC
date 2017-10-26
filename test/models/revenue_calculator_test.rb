require "test_helper"

class RevenueCalculatorTest < ActiveSupport::TestCase

  [
    [0, 1],
    [49_999_999, 1],
    [50_000_000, 2],
    [249_999_999, 2],
    [250_000_000, 3],
    [999_999_999, 3],
    [1_000_000_000, 4],
    [4_999_999_999, 4],
    [5_000_000_000, 5],
    [999_999_999_999, 5],
  ].each do |precise_revenue_dollars, expected_bracket|
    precise_revenue = Money.from_amount(precise_revenue_dollars)

    test "converts #{precise_revenue.format} to bracket: #{expected_bracket}" do
      bracket = RevenueCalculator.calculate_bracketed_revenue(precise_revenue)
      assert_equal expected_bracket, bracket
    end
  end

  test "converts nil to nil" do
    assert_nil RevenueCalculator.calculate_bracketed_revenue(nil)
  end

end
