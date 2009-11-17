class RemoveContactsPassword < ActiveRecord::Migration
  def self.up
    remove_column :contacts, :password
  end

  def self.down
    add_column :contacts, :password, :string
  end
end
