class TightenConstraintsOnActionPlatformTables < ActiveRecord::Migration
  def change
    change_column :action_platform_orders, :organization_id, :integer, null: false
    change_column :action_platform_orders, :financial_contact_id, :integer, null: false
    change_column :action_platform_orders, :status, :integer, null: false, default: 0

    change_column :action_platform_subscriptions, :contact_id, :integer, null: false
    change_column :action_platform_subscriptions, :platform_id, :integer, null: false
    change_column :action_platform_subscriptions, :order_id, :integer, null: false
    change_column :action_platform_subscriptions, :organization_id, :integer, null: false
    change_column :action_platform_subscriptions, :status, :integer, null: false

    change_column :action_platform_platforms, :name, :string, null: false
    change_column :action_platform_platforms, :description, :text, null: false
    change_column :action_platform_platforms, :slug, :string, null: false, limit: 32
  end

end
