class AddPasswordUpgradedToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :password_upgraded, :boolean, null: false, default: false
  end
end
