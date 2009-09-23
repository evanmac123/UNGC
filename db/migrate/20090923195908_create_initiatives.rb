class CreateInitiatives < ActiveRecord::Migration
  def self.up
    create_table :initiatives do |t|
      t.string :name
      t.integer :old_id

      t.timestamps
    end
  end

  def self.down
    drop_table :initiatives
  end
end
