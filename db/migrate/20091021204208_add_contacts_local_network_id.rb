class AddContactsLocalNetworkId < ActiveRecord::Migration
  def self.up
    add_column :contacts, :local_network_id, :integer
  end

  def self.down
    remove_column :contacts, :local_network_id
  end
end
