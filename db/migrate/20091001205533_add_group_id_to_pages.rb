class AddGroupIdToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :group_id, :integer
    add_index :pages, :group_id
  end

  def self.down
    remove_column :pages, :group_id
  end
end
