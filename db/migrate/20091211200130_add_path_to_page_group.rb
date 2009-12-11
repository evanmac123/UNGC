class AddPathToPageGroup < ActiveRecord::Migration
  def self.up
    add_column :page_groups, :path_stub, :string
  end

  def self.down
    remove_column :page_groups, :path_stub
  end
end
