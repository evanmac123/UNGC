class MoveUploadedFileToPaperclip < ActiveRecord::Migration
  def self.up
    remove_column :uploaded_files, :size
    remove_column :uploaded_files, :content_type
    remove_column :uploaded_files, :filename

    add_column :uploaded_files, :attachment_file_name,    :string
    add_column :uploaded_files, :attachment_file_size,    :integer
    add_column :uploaded_files, :attachment_content_type, :string
    add_column :uploaded_files, :attachment_updated_at,   :datetime
  end

  def self.down
    remove_column :uploaded_files, :attachment_file_name
    remove_column :uploaded_files, :attachment_file_size
    remove_column :uploaded_files, :attachment_content_type
    remove_column :uploaded_files, :attachment_updated_at

    add_column :uploaded_files, :size,         :integer
    add_column :uploaded_files, :content_type, :string
    add_column :uploaded_files, :filename,     :string
  end
end
