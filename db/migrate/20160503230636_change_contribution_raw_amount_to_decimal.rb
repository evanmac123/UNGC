class ChangeContributionRawAmountToDecimal < ActiveRecord::Migration
  def change
    change_column :contributions, :raw_amount, :decimal, precision: 10, scale: 2
  end
end
