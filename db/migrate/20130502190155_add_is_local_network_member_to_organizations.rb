class AddIsLocalNetworkMemberToOrganizations < ActiveRecord::Migration
  def self.up
    add_column :organizations, :is_local_network_member, :boolean
  end

  def self.down
    remove_column :organizations, :is_local_network_member
  end
end