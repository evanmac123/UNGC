class AddHabtmForContactsRoles < ActiveRecord::Migration
  def self.up
    create_table :contacts_roles, :id => false do |t|
      t.integer :contact_id, :role_id
    end
  end

  def self.down
    drop_table :contacts_roles
  end
end
