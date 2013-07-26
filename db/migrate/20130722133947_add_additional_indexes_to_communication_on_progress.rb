class AddAdditionalIndexesToCommunicationOnProgress < ActiveRecord::Migration
  def self.up
    add_index :communication_on_progresses, :differentiation
    add_index :communication_on_progresses, :organization_id
  end

  def self.down
    remove_index :communication_on_progresses, :differentiation
    remove_index :communication_on_progresses, :organization_id
  end
end
