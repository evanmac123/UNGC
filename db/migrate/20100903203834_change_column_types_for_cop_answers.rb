class ChangeColumnTypesForCopAnswers < ActiveRecord::Migration
  def self.up
    change_column :cop_answers, :text, :text, :null => false
  end

  def self.down
    change_column :cop_answers, :text, :string, :null => false
  end
end
