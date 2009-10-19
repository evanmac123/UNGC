class AddApprovalToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :approved, :boolean
    add_column :events, :approved_at, :datetime
    add_column :events, :approved_by_id, :integer
  end

  def self.down
    remove_column :events, :approved_by_id
    remove_column :events, :approved_at
    remove_column :events, :approved
  end
end
