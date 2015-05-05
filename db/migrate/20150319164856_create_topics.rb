class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.string :name, null: false
      t.integer :parent_id, index: true
      t.timestamps null: false
    end
    add_foreign_key :topics, :topics, column: :parent_id
  end
end
