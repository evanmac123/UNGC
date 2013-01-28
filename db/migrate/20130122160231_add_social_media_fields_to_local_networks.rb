class AddSocialMediaFieldsToLocalNetworks < ActiveRecord::Migration
  def self.up
    add_column :local_networks, :twitter, :string
    add_column :local_networks, :facebook, :string
    add_column :local_networks, :linkedin, :string
  end

  def self.down
    remove_column :local_networks, :linkedin
    remove_column :local_networks, :facebook
    remove_column :local_networks, :twitter
  end
end