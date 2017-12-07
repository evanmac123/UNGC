class ChangeActionPlatformDescription < ActiveRecord::Migration
  def up
    change_column :action_platform_platforms, :description, :string, limit: 1_000
  end

  def down
    change_column :action_platform_platforms, :description, :text
  end
end
