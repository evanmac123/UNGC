class CreateLogoFiles < ActiveRecord::Migration
  def self.up
    create_table :logo_files do |t|
      t.string :name
      t.string :description
      t.integer :old_id
      t.string :thumbnail
      t.string :file

      t.timestamps
    end
  end

  def self.down
    drop_table :logo_files
  end
end
