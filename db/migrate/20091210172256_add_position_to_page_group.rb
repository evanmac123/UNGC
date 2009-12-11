class AddPositionToPageGroup < ActiveRecord::Migration
  def self.up
    add_column :page_groups, :position, :integer
  end

  def self.down
    remove_column :page_groups, :position
  end
end
