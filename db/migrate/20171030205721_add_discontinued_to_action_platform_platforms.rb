class AddDiscontinuedToActionPlatformPlatforms < ActiveRecord::Migration
  def change
    add_column :action_platform_platforms, :discontinued, :boolean, default: false, null: false
  end
end
