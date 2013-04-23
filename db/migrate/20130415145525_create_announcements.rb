class CreateAnnouncements < ActiveRecord::Migration
    def self.up
      create_table :announcements do |t|
        t.integer :local_network_id
        t.integer :principle_id
        t.string  :title
        t.string  :description
        t.date    :date
        t.timestamps
      end
    end

    def self.down
      drop_table :announcements
    end
  end
