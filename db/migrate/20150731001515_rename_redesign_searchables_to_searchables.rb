class RenameRedesignSearchablesToSearchables < ActiveRecord::Migration
  def change
    rename_table :redesign_searchables, :searchables
  end
end
