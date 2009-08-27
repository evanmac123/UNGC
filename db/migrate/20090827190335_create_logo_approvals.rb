class CreateLogoApprovals < ActiveRecord::Migration
  def self.up
    create_table :logo_approvals do |t|
      t.integer :old_id
      t.integer :logo_request_id
      t.integer :logo_file_id

      t.timestamps
    end
  end

  def self.down
    drop_table :logo_approvals
  end
end
