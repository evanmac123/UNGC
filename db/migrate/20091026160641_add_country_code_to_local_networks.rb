class AddCountryCodeToLocalNetworks < ActiveRecord::Migration
  def self.up
    add_column :local_networks, :code, :string
    add_index :local_networks, :code
  end

  def self.down
    remove_column :local_networks, :code
  end
end
