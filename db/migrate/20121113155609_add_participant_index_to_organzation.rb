class AddParticipantIndexToOrganzation < ActiveRecord::Migration
  def self.up
    add_index :organizations, :participant
  end

  def self.down
    remove_index :organizations, :participant
  end
end