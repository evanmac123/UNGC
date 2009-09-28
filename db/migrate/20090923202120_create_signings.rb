class CreateSignings < ActiveRecord::Migration
  def self.up
    create_table :signings do |t|
      t.integer :old_id
      t.integer :initiative_id
      t.integer :organization_id
      t.date :added_on

      t.timestamps
    end
  end

  def self.down
    drop_table :signings
  end
end
