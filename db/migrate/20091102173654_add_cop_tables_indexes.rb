class AddCopTablesIndexes < ActiveRecord::Migration
  def self.up
    add_index :cop_questions, [:principle_area_id, :position]
    add_index :cop_attributes, [:cop_question_id, :position]
    add_index :cop_answers, :cop_id
  end

  def self.down
    remove_index :cop_questions, [:principle_area_id, :position]
    remove_index :cop_attributes, [:cop_question_id, :position]
    remove_index :cop_answers, :cop_id
  end
end
