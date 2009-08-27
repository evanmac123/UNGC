class CreateCopScores < ActiveRecord::Migration
  def self.up
    create_table :cop_scores do |t|
      t.string :description
      t.integer :old_id

      t.timestamps
    end
  end

  def self.down
    drop_table :cop_scores
  end
end
