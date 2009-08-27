class CreateLogoPublications < ActiveRecord::Migration
  def self.up
    create_table :logo_publications do |t|
      t.string :name
      t.integer :old_id
      t.integer :parent_id
      t.integer :display_order

      t.timestamps
    end
  end

  def self.down
    drop_table :logo_publications
  end
end
