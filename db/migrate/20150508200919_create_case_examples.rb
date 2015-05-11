class CreateCaseExamples < ActiveRecord::Migration
  def change
    create_table :case_examples do |t|
      t.string :company
      t.references :country, index: true
      t.boolean :is_participant
      t.attachment :file

      t.timestamps null: false
    end
  end
end
