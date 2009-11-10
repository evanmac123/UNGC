class CreateSearchables < ActiveRecord::Migration
  def self.up
    create_table :searchables do |t|
      t.string :title
      t.text :content
      t.string :url
      t.string :document_type
      t.datetime :last_indexed_at

      t.timestamps
    end
  end

  def self.down
    drop_table :searchables
  end
end
