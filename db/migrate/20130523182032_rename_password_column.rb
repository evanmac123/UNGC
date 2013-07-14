class RenamePasswordColumn < ActiveRecord::Migration
  def change
    rename_column :contacts, :password, :plaintext_password
  end
end
