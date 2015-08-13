class RenameSearchablesToOldSearchables < ActiveRecord::Migration
  def change
    rename_table :searchables, :old_searchables
  end
end
