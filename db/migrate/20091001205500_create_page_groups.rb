class CreatePageGroups < ActiveRecord::Migration
  def self.up
    create_table :page_groups do |t|
      t.string :name
      t.boolean :display_in_navigation
      t.string :slug

      t.timestamps
    end
  end

  def self.down
    drop_table :page_groups
  end
end
