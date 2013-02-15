class AddIndexesToLocalNetworksEventsPrinciples < ActiveRecord::Migration
  def self.up
    add_index :local_network_events_principles, :local_network_event_id
    add_index :local_network_events_principles, :principle_id
  end

  def self.down
    remove_index :local_network_events_principles, :local_network_event_id
    remove_index :local_network_events_principles, :principle_id
  end
end
