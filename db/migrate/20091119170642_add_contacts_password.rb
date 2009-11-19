class AddContactsPassword < ActiveRecord::Migration
  def self.up
    add_column :contacts, :password, :string
  end

  def self.down
    remove_column :contacts, :password
  end
end
