class AddOrganizationIdToActionPlatformSubscriptions < ActiveRecord::Migration
  def change
    add_reference :action_platform_subscriptions, :organization, index: true, foreign_key: true
  end
end
