class CreateMeetings < ActiveRecord::Migration
  def self.up
    create_table :meetings do |t|
      t.integer :local_network_id
      t.string  :meeting_type
      t.date    :date
      t.timestamps
    end
  end

  def self.down
    drop_table :meetings
  end
end
