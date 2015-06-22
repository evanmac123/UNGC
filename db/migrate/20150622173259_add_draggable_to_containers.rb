class AddDraggableToContainers < ActiveRecord::Migration
  def change
    add_column :redesign_containers, :draggable, :boolean, default: true
  end
end
