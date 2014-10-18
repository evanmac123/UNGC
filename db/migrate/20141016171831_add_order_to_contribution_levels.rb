class AddOrderToContributionLevels < ActiveRecord::Migration
  def change
    add_column :contribution_levels, :order, :integer
    add_index :contribution_levels, :order
  end
end
