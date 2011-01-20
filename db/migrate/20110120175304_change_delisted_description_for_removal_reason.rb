class ChangeDelistedDescriptionForRemovalReason < ActiveRecord::Migration
  def self.up
    reason = RemovalReason.find(4)
    reason.update_attributes(:description => 'Failure to communicate progress')
  end

  def self.down
    reason = RemovalReason.find(4)
    reason.update_attributes(:description => 'Expulsion for failure to communicate progress')
  end
end
