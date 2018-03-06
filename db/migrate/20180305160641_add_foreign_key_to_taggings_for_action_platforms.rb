class AddForeignKeyToTaggingsForActionPlatforms < ActiveRecord::Migration
  def change
    add_foreign_key :taggings, :action_platform_platforms, column: :action_platform_id
  end
end
