class RenameLoginToUsername < ActiveRecord::Migration
  def up
    rename_column :contacts, :login, :username
  end

  def down
    rename_column :contacts, :username, :login
  end
end
