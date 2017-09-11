class AddCopAttributeIdIndexToCopAnswers < ActiveRecord::Migration
  def change
    # add_foreign_key :cop_answers, :cop_attributes
    add_index :cop_answers, :cop_attribute_id
  end
end
