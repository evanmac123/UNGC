class CreateSectors < ActiveRecord::Migration
  def self.up
    create_table :sectors do |t|
      t.string :name
      t.integer :old_id
      t.string :icb_number
      t.integer :parent_id

      t.timestamps
    end
  end

  def self.down
    drop_table :sectors
  end
end
