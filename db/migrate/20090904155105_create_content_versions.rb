class CreateContentVersions < ActiveRecord::Migration
  def self.up
    create_table :content_versions do |t|
      t.integer :number
      t.boolean :approved
      t.datetime :approved_at
      t.integer :approved_by
      t.string :path
      t.text :content
      t.integer :created_by_id

      t.timestamps
    end
    
    add_index :content_versions, :approved
    add_index :content_versions, :path
    add_index :content_versions, :number
  end

  def self.down
    drop_table :content_versions
  end
end
