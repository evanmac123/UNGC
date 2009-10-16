class RemoveRolesFromContacts < ActiveRecord::Migration
  def self.up
    remove_column :contacts, :role_id
  end

  def self.down
    add_column :contacts, :role_id, :integer
  end
end
