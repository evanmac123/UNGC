class AddApprovalToEventsAgain < ActiveRecord::Migration
  def self.up
    add_column :events, :approval, :string
  end

  def self.down
    remove_column :events, :approval
  end
end
