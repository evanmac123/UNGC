class UpdateIndexOnContainer < ActiveRecord::Migration
  def change
    remove_index :redesign_containers, [:layout, :slug]
    add_index :redesign_containers, [:parent_container_id, :slug], unique: true
  end
end
