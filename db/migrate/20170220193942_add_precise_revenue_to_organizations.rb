class AddPreciseRevenueToOrganizations < ActiveRecord::Migration
  def up
    add_column :organizations, :precise_revenue_cents, :integer, limit: 8
    add_column :organizations, :precise_revenue_currency, :string, null: false, default: "USD"
  end

  def down
    remove_column :organizations, :precise_revenue_cents
    remove_column :organizations, :precise_revenue_currency
  end
end
