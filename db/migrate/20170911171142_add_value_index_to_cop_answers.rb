class AddValueIndexToCopAnswers < ActiveRecord::Migration
  def change
    add_index :cop_answers, :value
  end
end
