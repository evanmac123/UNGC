class CreateLogoFilesLogoRequests < ActiveRecord::Migration
  def self.up
    create_table :logo_files_logo_requests, :id => false do |t|
      t.integer :logo_file_id
      t.integer :logo_request_id
    end
  end

  def self.down
    drop_table :logo_files_logo_requests
  end
end
