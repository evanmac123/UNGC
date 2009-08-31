class AddOrganizationsState < ActiveRecord::Migration
  def self.up
    add_column :organizations, :state, :string
  end

  def self.down
    remove_column :organizations, :state
  end
end
