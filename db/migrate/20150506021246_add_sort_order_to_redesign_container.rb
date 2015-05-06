class AddSortOrderToRedesignContainer < ActiveRecord::Migration
  def change
    add_column :redesign_containers, :sort_order, :integer, default: 0
  end
end
