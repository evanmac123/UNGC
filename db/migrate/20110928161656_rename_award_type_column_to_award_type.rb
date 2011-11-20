class RenameAwardTypeColumnToAwardType < ActiveRecord::Migration
  def self.up
    rename_column :awards, :type, :award_type
  end

  def self.down
    rename_column :awards, :award_type, :type
  end
end