class CreateRemovalReasons < ActiveRecord::Migration
  def self.up
    create_table :removal_reasons do |t|
      t.string :description
      t.integer :old_id

      t.timestamps
    end
  end

  def self.down
    drop_table :removal_reasons
  end
end
