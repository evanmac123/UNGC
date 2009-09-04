class AddLogoCommentsAttachment < ActiveRecord::Migration
  def self.up
    add_column :logo_comments, :attachment_file_name, :string
    add_column :logo_comments, :attachment_content_type, :string
    add_column :logo_comments, :attachment_file_size, :integer
    add_column :logo_comments, :attachment_updated_at, :datetime
  end

  def self.down
    remove_column :logo_comments, :attachment_updated_at
    remove_column :logo_comments, :attachment_file_size
    remove_column :logo_comments, :attachment_content_type
    remove_column :logo_comments, :attachment_file_name
  end
end
