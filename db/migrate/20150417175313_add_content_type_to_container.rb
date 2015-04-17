class AddContentTypeToContainer < ActiveRecord::Migration
  def change
    add_column :redesign_containers, :content_type, :integer, null: false, default: 0
    add_index :redesign_containers, :content_type
  end
end
