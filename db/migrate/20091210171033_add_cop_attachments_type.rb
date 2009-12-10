class AddCopAttachmentsType < ActiveRecord::Migration
  def self.up
    add_column :cop_files, :attachment_type, :string
    add_column :cop_files, :language_id, :integer
    remove_column :cop_files, :name
    
    add_column :cop_links, :attachment_type, :string
    add_column :cop_links, :language_id, :integer
    remove_column :cop_links, :name
  end

  def self.down
    remove_column :cop_files, :attachment_type
    remove_column :cop_files, :language_id
    add_column :cop_files, :name, :string
    
    remove_column :cop_links, :attachment_type
    remove_column :cop_links, :language_id
    add_column :cop_links, :name, :string
  end
end
