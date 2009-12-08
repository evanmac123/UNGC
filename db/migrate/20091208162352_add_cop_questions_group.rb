class AddCopQuestionsGroup < ActiveRecord::Migration
  def self.up
    add_column :cop_questions, :grouping, :string
  end

  def self.down
    remove_column :cop_questions, :grouping
  end
end
