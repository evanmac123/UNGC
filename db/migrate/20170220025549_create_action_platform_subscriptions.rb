class CreateActionPlatformSubscriptions < ActiveRecord::Migration
  def change
    create_table :action_platform_subscriptions do |t|
      t.references :contact, index: true, foreign_key: true
      t.references :platform
      t.references :order

      t.timestamps null: false
    end
    add_index :action_platform_subscriptions, :platform_id
    add_index :action_platform_subscriptions, :order_id

    add_foreign_key(:action_platform_subscriptions,
                    :action_platform_platforms,
                    column: :platform_id)
    add_foreign_key(:action_platform_subscriptions,
                    :action_platform_orders,
                    column: :order_id)
  end
end
