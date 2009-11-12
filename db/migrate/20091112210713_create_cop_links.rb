class CreateCopLinks < ActiveRecord::Migration
  def self.up
    create_table :cop_links do |t|
      t.integer :cop_id
      t.string :name
      t.string :url

      t.timestamps
    end
  end

  def self.down
    drop_table :cop_links
  end
end
