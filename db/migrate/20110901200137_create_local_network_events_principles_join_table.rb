class CreateLocalNetworkEventsPrinciplesJoinTable < ActiveRecord::Migration
  def self.up
    create_table :local_network_events_principles, :id => false do |t|
      t.integer "local_network_event_id"
      t.integer "principle_id"
    end
  end

  def self.down
    drop_table :local_network_events_principles
  end
end

