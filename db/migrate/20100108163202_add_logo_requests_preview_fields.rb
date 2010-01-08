class AddLogoRequestsPreviewFields < ActiveRecord::Migration
  def self.up
    add_column :logo_files, :preview_file_name, :string
    add_column :logo_files, :preview_content_type, :string
    add_column :logo_files, :preview_file_size, :integer
    add_column :logo_files, :preview_updated_at, :datetime
  end

  def self.down
    remove_column :logo_files, :preview_file_name
    remove_column :logo_files, :preview_content_type
    remove_column :logo_files, :preview_file_size
    remove_column :logo_files, :preview_updated_at
  end
end
