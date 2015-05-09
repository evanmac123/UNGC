class AddCaseExampleToTaggings < ActiveRecord::Migration
  def change
    add_reference :taggings, :case_example, index: true, foreign_key: true
  end
end
