class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.string :name, null: false
      t.string :type, index: true
      t.integer :issue_area_id, index: true
      t.timestamps null: false
    end
    add_foreign_key :issues, :issues, column: :issue_area_id
  end
end
