class CreateAuthorsResources < ActiveRecord::Migration
  def up
    create_table "authors_resources", :id => false, :force => true do |t|
      t.integer "author_id"
      t.integer "resource_id"
      t.timestamps
    end
  end


  def down
    drop_table "authors_resources"
  end
end
