class AddPathToRedesignContainers < ActiveRecord::Migration
  def up
    add_column :redesign_containers, :path, :string, limit: 255
    add_index :redesign_containers, :path, unique: true
  end

  def down
    remove_column :redesign_containers, :path
    remove_index :redesign_containers, :path, unique: true
  end
end
