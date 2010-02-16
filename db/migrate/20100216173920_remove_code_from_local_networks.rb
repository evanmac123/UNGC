class RemoveCodeFromLocalNetworks < ActiveRecord::Migration
  def self.up
    remove_column :local_networks, :code
  end

  def self.down
    add_column :local_networks, :code, :varchar
  end
end
