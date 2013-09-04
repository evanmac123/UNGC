class RemovePublishedOnFromResources < ActiveRecord::Migration
  def up
    remove_column :resources, :published_on
  end

  def down
    add_column :resources, :published_on, :date
  end
end
