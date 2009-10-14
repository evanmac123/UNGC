class AddRoleToContacts < ActiveRecord::Migration
  def self.up
    add_column :contacts, :role_id, :integer
  end

  def self.down
    remove_column :contacts, :role_id
  end
end
