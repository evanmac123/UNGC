class AddDeltaToSearchables < ActiveRecord::Migration
  def self.up
    add_column :searchables, :delta, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :searchables, :delta
  end
end
