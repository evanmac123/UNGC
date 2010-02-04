class AddCopsWebBasedOnly < ActiveRecord::Migration
  def self.up
    add_column :communication_on_progresses, :web_based, :boolean
  end

  def self.down
    remove_column :communication_on_progresses, :web_based
  end
end
