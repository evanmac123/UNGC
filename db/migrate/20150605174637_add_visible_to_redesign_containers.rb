class AddVisibleToRedesignContainers < ActiveRecord::Migration
  def change
    add_column :redesign_containers, :visible, :boolean, default: true
  end
end
