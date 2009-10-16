class RemoveManagerFromCountries < ActiveRecord::Migration
  def self.up
    remove_column :countries, :manager
  end

  def self.down
    add_column :countries, :manager, :string
  end
end
