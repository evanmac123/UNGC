class AddCopQuestionYear < ActiveRecord::Migration
  def self.up
    add_column :cop_questions, :year, :integer
  end

  def self.down
    remove_column :cop_questions, :year
  end
end