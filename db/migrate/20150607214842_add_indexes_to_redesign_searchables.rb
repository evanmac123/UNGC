class AddIndexesToRedesignSearchables < ActiveRecord::Migration
  def change
    add_index :redesign_searchables, :url
    add_index :redesign_searchables, [:document_type, :url]
  end
end
