class AddAttachmentUnmodifiedFilenameToUploadedFiles < ActiveRecord::Migration
  def self.up
    add_column :uploaded_files, :attachment_unmodified_filename, :string
  end

  def self.down
    remove_column :uploaded_files, :attachment_unmodified_filename
  end
end
