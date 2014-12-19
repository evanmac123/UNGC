class AddIndexesToContactsRoles < ActiveRecord::Migration
  def change
    add_index :contacts_roles, :contact_id
    add_index :contacts_roles, :role_id
  end
end
