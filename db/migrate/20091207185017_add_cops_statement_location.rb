class AddCopsStatementLocation < ActiveRecord::Migration
  def self.up
    add_column :communication_on_progresses, :statement_location, :string
  end

  def self.down
    remove_column :communication_on_progresses, :statement_location
  end
end
