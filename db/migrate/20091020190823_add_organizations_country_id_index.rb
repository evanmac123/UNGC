class AddOrganizationsCountryIdIndex < ActiveRecord::Migration
  def self.up
    add_index :organizations, :country_id
  end

  def self.down
    remove_index :organizations, :country_id
  end
end
