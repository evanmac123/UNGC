class CreateResourceLinks < ActiveRecord::Migration
  def up
    create_table :resource_links do |t|
      t.string :url
      t.string :title
      t.string :link_type
      t.integer :resource_id
      t.integer :language_id
      t.timestamps
    end
  end

  def down
    drop_table :resource_links
  end
end
