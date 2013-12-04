class AddImageToResources < ActiveRecord::Migration
  def up
    add_attachment :resources, :image
  end
  def down
    remove_attachment :resources, :image
  end
end
