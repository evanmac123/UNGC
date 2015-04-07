class AddChildContainersCountToContainers < ActiveRecord::Migration
  def change
    add_column :redesign_containers, :child_containers_count, :integer, default: 0, null: false
  end
end
