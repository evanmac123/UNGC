class AddTextToCopAnswers < ActiveRecord::Migration
  def self.up
    add_column :cop_answers, :text, :string
  end

  def self.down
    remove_column :cop_answers, :text
  end
end
