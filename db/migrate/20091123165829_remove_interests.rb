class RemoveInterests < ActiveRecord::Migration
  def self.up
    drop_table :interests
  end

  def self.down
    create_table "interests", :force => true do |t|
      t.string   "name"
      t.integer  "old_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
