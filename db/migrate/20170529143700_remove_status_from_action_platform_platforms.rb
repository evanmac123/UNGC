class RemoveStatusFromActionPlatformPlatforms < ActiveRecord::Migration
  def change
    remove_column :action_platform_platforms, :status, :integer
  end
end
