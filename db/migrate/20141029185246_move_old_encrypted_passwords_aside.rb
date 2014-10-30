class MoveOldEncryptedPasswordsAside < ActiveRecord::Migration
  def up
    rename_column :contacts, :encrypted_password, :old_encrypted_password
    add_column :contacts, :encrypted_password, :string
    execute 'update contacts set encrypted_password = old_encrypted_password;'
  end

  def down
    remove_column :contacts, :encrypted_password
    rename_column :contacts, :old_encrypted_password, :encrypted_password
  end
end
