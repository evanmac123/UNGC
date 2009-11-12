class RemoveCopFilesUrl < ActiveRecord::Migration
  def self.up
    remove_column :cop_files, :url
  end

  def self.down
    add_column :cop_files, :url, :string
  end
end
