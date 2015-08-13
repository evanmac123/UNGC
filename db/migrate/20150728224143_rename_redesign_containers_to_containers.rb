class RenameRedesignContainersToContainers < ActiveRecord::Migration
  def up
    remove_foreign_key :taggings, :redesign_containers
    rename_table :redesign_containers, :containers
    rename_column :taggings, :redesign_container_id, :container_id
    add_foreign_key :taggings, :containers
  end

  def down
    remove_foreign_key :taggings, :containers
    rename_column :taggings, :container_id, :redesign_container_id
    rename_table :containers, :redesign_containers
    add_foreign_key :taggings, :redesign_containers
  end
end
