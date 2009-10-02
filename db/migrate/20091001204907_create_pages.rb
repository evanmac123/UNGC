class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.string :path
      t.string :title
      t.string :slug
      t.text :content
      t.integer :parent_id
      t.integer :position
      t.boolean :display_in_navigation
      t.boolean :approved
      t.datetime :approved_at
      t.integer :approved_by_id
      t.integer :created_by_id
      t.integer :updated_by_id
      t.boolean :dynamic_content
      t.integer :version_number

      t.timestamps
    end
    
    add_index :pages, :path
    add_index :pages, :parent_id
    add_index :pages, :version_number
  end

  def self.down
    drop_table :pages
  end
end
