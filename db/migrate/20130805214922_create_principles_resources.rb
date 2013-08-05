class CreatePrinciplesResources < ActiveRecord::Migration
  def up
    create_table "principles_resources", :id => false, :force => true do |t|
      t.integer "principle_id"
      t.integer "resource_id"
      t.timestamps
    end
  end


  def down
    drop_table "principles_resources"
  end
end
