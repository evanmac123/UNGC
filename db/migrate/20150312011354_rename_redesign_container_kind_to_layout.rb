class RenameRedesignContainerKindToLayout < ActiveRecord::Migration
  def change
    rename_column :redesign_containers, :kind, :layout
  end
end
