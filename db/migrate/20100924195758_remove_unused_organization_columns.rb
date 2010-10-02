class RemoveUnusedOrganizationColumns < ActiveRecord::Migration
  def self.up
    remove_column :organizations, :cop_status
    remove_column :organizations, :one_year_member_on
  end

  def self.down    
    add_column :organizations, :cop_status, :integer
    add_column :organizations, :one_year_member_on, :string
  end
end
