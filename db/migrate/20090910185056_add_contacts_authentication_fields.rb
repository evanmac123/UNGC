class AddContactsAuthenticationFields < ActiveRecord::Migration
  def self.up
    add_column :contacts, :remember_token_expires_at, :datetime
    add_column :contacts, :remember_token, :string
  end

  def self.down
    remove_column :contacts, :remember_token
    remove_column :contacts, :remember_token_expires_at
  end
end
