class AddNewPathToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :change_path, :string
  end

  def self.down
    remove_column :pages, :change_path
  end
end
