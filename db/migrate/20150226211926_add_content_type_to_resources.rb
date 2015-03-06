class AddContentTypeToResources < ActiveRecord::Migration
  def change
    add_column :resources, :content_type, :integer
    add_index :resources, :content_type
  end
end
