class AddCopStatusToOrganization < ActiveRecord::Migration
  def self.up
    add_column :organizations, :cop_status, :integer
  end

  def self.down
    remove_column :organizations, :cop_alert
  end
end
