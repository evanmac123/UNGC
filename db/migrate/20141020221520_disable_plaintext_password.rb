class DisablePlaintextPassword < ActiveRecord::Migration
  def change
    rename_column :contacts, :plaintext_password, :plaintext_password_disabled
  end
end
