class AddDepthAndTreePathToContainers < ActiveRecord::Migration
  def change
    add_column :redesign_containers, :depth, :integer, default: 0, null: false
    add_column :redesign_containers, :tree_path, :string, default: '', null: false

    add_index :redesign_containers, :depth
  end
end
