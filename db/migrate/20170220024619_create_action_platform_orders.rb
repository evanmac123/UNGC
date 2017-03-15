class CreateActionPlatformOrders < ActiveRecord::Migration
  def up
    create_table :action_platform_orders do |t|
      t.references :organization
      t.integer :financial_contact_id, index: true
      t.integer :status
      t.monetize :price

      t.timestamps null: false
    end
    change_column :action_platform_orders, :price_cents, :integer, limit: 8
    add_foreign_key :action_platform_orders, :contacts, column: :financial_contact_id
  end

  def down
    drop_table :action_platform_orders
  end
end
