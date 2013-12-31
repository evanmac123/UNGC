class RemoveManagerIdFromLocalNetworks < ActiveRecord::Migration
  def up
    remove_column :local_networks, :manager_id
  end

  def down
    add_column :local_networks, :manager_id, :integer
  end
end
