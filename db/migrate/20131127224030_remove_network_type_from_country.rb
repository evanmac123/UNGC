class RemoveNetworkTypeFromCountry < ActiveRecord::Migration
  def up
    remove_column :countries, :network_type
  end

  def down
    add_column :countries, :network_type, :integer
  end
end
