class AddCopStartEndDates < ActiveRecord::Migration
  def self.up
    add_column :communication_on_progresses, :starts_on, :date
    add_column :communication_on_progresses, :ends_on, :date
  end

  def self.down
    remove_column :communication_on_progresses, :starts_on, :date
    remove_column :communication_on_progresses, :ends_on, :date
  end
end
