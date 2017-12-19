class AddStateToApSubs < ActiveRecord::Migration
  def up
    # These two dates are used to set defaults start/end dates for each platform
    add_column :action_platform_platforms, :default_starts_at, :date,
               null: true, after: :description
    add_column :action_platform_platforms, :default_ends_at, :date,
               null: true, after: :default_starts_at


    add_column :action_platform_subscriptions, :starts_on, :date,
               null: true, after: :status

    ActionPlatform::Subscription.update_all('starts_on = created_at')
    add_column :action_platform_subscriptions, :state, :string, limit: 20,
               null: false, index: true, default: 'pending'

    change_column :action_platform_subscriptions, :status, :integer, null: true

    # Migrate away from status to state
    ActionPlatform::Subscription
      .where(status: 1)
      .update_all(state: :approved)

    # Migrate away from status and remove date ranges for pending so they can be easily set when approved
    ActionPlatform::Subscription
        .where(status: 0)
        .update_all(state: :pending, starts_on: nil, expires_on: nil)
  end

  def down
    ActionPlatform::Subscription
        .where(state: :approved)
        .update_all(status: 1)

    ActionPlatform::Subscription
        .where(state: :pending)
        .update_all(status: 0)

    change_column :action_platform_subscriptions, :status, :integer, null: false

    remove_column :action_platform_subscriptions, :state
    remove_column :action_platform_subscriptions, :starts_on

    remove_column :action_platform_platforms, :default_starts_at
    remove_column :action_platform_platforms, :default_ends_at
  end
end
