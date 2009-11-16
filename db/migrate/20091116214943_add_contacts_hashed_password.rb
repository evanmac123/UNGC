class AddContactsHashedPassword < ActiveRecord::Migration
  def self.up
    add_column :contacts, :hashed_password, :string
  end

  def self.down
    remove_column :contacts, :hashed_password
  end
end
