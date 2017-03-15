class AddSlugToActionPlatformPlatforms < ActiveRecord::Migration
  def change
    add_column :action_platform_platforms, :slug, :string
  end
end
