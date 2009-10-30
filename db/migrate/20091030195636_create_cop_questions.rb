class CreateCopQuestions < ActiveRecord::Migration
  def self.up
    create_table :cop_questions do |t|
      t.integer :principle_area_id
      t.string :text
      t.boolean :area_selected
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :cop_questions
  end
end
