class RemoveLocalNetworkFromOrganizations < ActiveRecord::Migration
  def self.up
    remove_column :organizations, :local_network
  end

  def self.down
    add_column :organizations, :local_network, :boolean
  end
end
