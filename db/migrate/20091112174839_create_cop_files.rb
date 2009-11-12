class CreateCopFiles < ActiveRecord::Migration
  def self.up
    create_table :cop_files do |t|
      t.integer :cop_id
      t.string :name
      t.string :url
      t.string :attachment_file_name
      t.string :attachment_content_type
      t.integer :attachment_file_size
      t.datetime :attachment_updated_at

      t.timestamps
    end
  end

  def self.down
    drop_table :cop_files
  end
end
