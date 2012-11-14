class AddIndexesToCommunicationOnProgress < ActiveRecord::Migration
  def self.up
    add_index :communication_on_progresses, :state
    add_index :communication_on_progresses, :created_at
  end

  def self.down
    remove_index :communication_on_progresses, :state
    remove_index :communication_on_progresses, :created_at
  end
end