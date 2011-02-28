class AddImplementationToCopQuestions < ActiveRecord::Migration
  def self.up
    add_column :cop_questions, :implementation, :string
  end

  def self.down
    remove_column :cop_questions, :implementation
  end
end
