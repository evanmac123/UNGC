class AddDescriptionToLocalNetworks < ActiveRecord::Migration
  def change
    add_column :local_networks, :description, :string
    add_attachment :local_networks, :image
  end
end
