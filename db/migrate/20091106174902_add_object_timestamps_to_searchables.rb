class AddObjectTimestampsToSearchables < ActiveRecord::Migration
  def self.up
    add_column :searchables, :object_created_at, :datetime
    add_column :searchables, :object_updated_at, :datetime
  end

  def self.down
    remove_column :searchables, :object_updated_at
    remove_column :searchables, :object_created_at
  end
end
