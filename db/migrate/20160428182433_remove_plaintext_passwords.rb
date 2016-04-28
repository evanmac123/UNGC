class RemovePlaintextPasswords < ActiveRecord::Migration
  def change
    remove_column :contacts, :plaintext_password_disabled, :string
    remove_column :contacts, :password_upgraded, :boolean
  end
end
