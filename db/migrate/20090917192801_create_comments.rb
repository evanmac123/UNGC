class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.text :body, :default => "" 
      t.references :commentable, :polymorphic => true
      t.references :contact
      t.timestamps
      
      # paperclip fields
      t.string   :attachment_file_name
      t.string   :attachment_content_type
      t.integer  :attachment_file_size
      t.datetime :attachment_updated_at
    end

    add_index :comments, :commentable_type
    add_index :comments, :commentable_id
    add_index :comments, :contact_id
  end

  def self.down
    drop_table :comments
  end
end
