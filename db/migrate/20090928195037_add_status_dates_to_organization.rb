class AddStatusDatesToOrganization < ActiveRecord::Migration
  def self.up
    add_column :organizations, :cop_due_on, :date
    add_column :organizations, :inactive_on, :date
    add_column :organizations, :one_year_member_on, :string
  end

  def self.down
    remove_column :organizations, :one_year_member_on
    remove_column :organizations, :inactive_on
    remove_column :organizations, :cop_due_on
  end
end
