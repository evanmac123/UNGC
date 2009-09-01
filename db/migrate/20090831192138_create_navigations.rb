class CreateNavigations < ActiveRecord::Migration
  def self.up
    create_table :navigations do |t|
      t.string :label
      t.string :href
      t.string :short
      t.integer :parent_id
      t.integer :position
      t.boolean :top_nav, :default => true

      t.timestamps
    end
    
    add_index :navigations, :parent_id
    add_index :navigations, :href
  end

  def self.down
    drop_table :navigations
  end
end
