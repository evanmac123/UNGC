class AddStatusToActionPlatformSubscriptions < ActiveRecord::Migration
  def change
    add_column :action_platform_subscriptions, :status, :integer
    add_column :action_platform_subscriptions, :expires_on, :date
  end
end
