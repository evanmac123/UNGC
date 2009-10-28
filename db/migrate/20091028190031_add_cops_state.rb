class AddCopsState < ActiveRecord::Migration
  def self.up
    add_column :communication_on_progresses, :state, :string
  end

  def self.down
    remove_column :communication_on_progresses, :state
  end
end
