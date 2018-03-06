class AddActionPlatformToTaggings < ActiveRecord::Migration
  def change
    add_column :taggings, :action_platform_id, :integer
    add_index :taggings, :action_platform_id
  end
end
