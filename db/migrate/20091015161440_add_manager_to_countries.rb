class AddManagerToCountries < ActiveRecord::Migration
  def self.up
    add_column :countries, :manager_id, :integer
  end

  def self.down
    remove_column :countries, :manager_id
  end
end
