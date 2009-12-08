class RemoveCopQuestionsSelected < ActiveRecord::Migration
  def self.up
    remove_column :cop_questions, :area_selected
  end

  def self.down
    add_column :cop_questions, :area_selected, :boolean
  end
end
