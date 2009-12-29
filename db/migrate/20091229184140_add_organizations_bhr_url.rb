class AddOrganizationsBhrUrl < ActiveRecord::Migration
  def self.up
    add_column :organizations, :bhr_url, :string
  end

  def self.down
    remove_column :organizations, :bhr_url
  end
end
