class DeleteCopFields < ActiveRecord::Migration
  def self.up
    remove_column :communication_on_progresses, :statement_location
  end

  def self.down
    add_column :communication_on_progresses, :statement_location, :string
  end
end
