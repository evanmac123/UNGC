class AddContactsResetPasswordToken < ActiveRecord::Migration
  def self.up
    add_column :contacts, :reset_password_token, :string
  end

  def self.down
    remove_column :contacts, :reset_password_token
  end
end
