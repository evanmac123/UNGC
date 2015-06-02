class CreateRedesignSearchable < ActiveRecord::Migration
  def change
    create_table :redesign_searchables do |t|
      t.datetime :last_indexed_at
      t.string :url
      t.string :document_type
      t.text :title
      t.text :content
      t.text :meta
      t.timestamps
    end
  end
end
