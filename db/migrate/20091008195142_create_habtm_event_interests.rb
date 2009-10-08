class CreateHabtmEventInterests < ActiveRecord::Migration
  def self.up
    create_table :events_interests, :id => false do |t|
      t.integer :event_id, :interest_id
    end
  end

  def self.down
    drop_table :events_interests
  end
end
