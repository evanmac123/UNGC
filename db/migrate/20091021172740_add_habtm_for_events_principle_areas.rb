class AddHabtmForEventsPrincipleAreas < ActiveRecord::Migration
  def self.up
    create_table :events_principles, :id => false do |t|
      t.integer :event_id, :principle_area_id
    end
  end

  def self.down
    drop_table :events_principles
  end
end
