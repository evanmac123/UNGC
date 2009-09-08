class DropLogoApprovals < ActiveRecord::Migration
  def self.up
    drop_table :logo_approvals
  end

  def self.down
    create_table "logo_approvals", :force => true do |t|
      t.integer  "old_id"
      t.integer  "logo_request_id"
      t.integer  "logo_file_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
