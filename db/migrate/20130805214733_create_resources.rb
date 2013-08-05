class CreateResources < ActiveRecord::Migration
  def up
    create_table :resources do |t|
      t.string :title
      t.text :description
      t.date :year
      t.string :image_url
      t.string :isbn
      t.date :published_on
      t.string :approval
      t.datetime :approved_at
      t.integer :approved_by_id
      t.timestamps
    end
  end

  def down
    drop_table :resources
  end
end
