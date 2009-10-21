class CreateLocalNetworks < ActiveRecord::Migration
  def self.up
    create_table :local_networks do |t|
      t.string :name
      t.string :manager
      t.string :url
      t.string :state

      t.timestamps
    end
    
    create_table :countries_local_networks, :id => false do |t|
      t.integer :country_id
      t.integer :local_network_id
    end
  end

  def self.down
    drop_table :local_networks
    drop_table :countries_local_networks
  end
end
