class RemoveImageUrlFromResources < ActiveRecord::Migration
  def up
    remove_column :resources, :image_url
  end

  def down
    add_column :resources, :image_url, :string
  end
end
