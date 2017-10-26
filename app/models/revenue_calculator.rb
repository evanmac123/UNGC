class RevenueCalculator

  def self.calculate_bracketed_revenue(precise_revenue)
    return nil if precise_revenue.blank?

    case
    when precise_revenue <= REVENUE_AMOUNTS[1] then 1
    when precise_revenue <= REVENUE_AMOUNTS[2] then 2
    when precise_revenue <= REVENUE_AMOUNTS[3] then 3
    when precise_revenue <= REVENUE_AMOUNTS[4] then 4
    when precise_revenue >= REVENUE_AMOUNTS[4] then 5
    end
  end

  def self.calculate_precise_revenue(bracketed_revenue)
    REVENUE_AMOUNTS[bracketed_revenue]
  end

  private

  REVENUE_AMOUNTS = {
    1 => Money.from_amount(49_999_999),
    2 => Money.from_amount(249_999_999),
    3 => Money.from_amount(999_999_999),
    4 => Money.from_amount(4_999_999_999),
    5 => Money.from_amount(5_000_000_000),
  }.freeze

end
