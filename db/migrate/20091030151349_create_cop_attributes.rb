class CreateCopAttributes < ActiveRecord::Migration
  def self.up
    create_table :cop_attributes do |t|
      t.integer :cop_question_id
      t.string :text
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :cop_attributes
  end
end
