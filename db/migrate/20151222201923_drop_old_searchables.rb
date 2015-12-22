class DropOldSearchables < ActiveRecord::Migration
  def change
      drop_table :old_searchables
  end
end
