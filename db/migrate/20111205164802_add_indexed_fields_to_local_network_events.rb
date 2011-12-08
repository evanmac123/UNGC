class AddIndexedFieldsToLocalNetworkEvents < ActiveRecord::Migration
  def self.up
    add_column :local_network_events, :country_id,   :integer
    add_column :local_network_events, :region,       :string
    add_column :local_network_events, :file_content, :text

    rows = execute("SELECT local_network_events.id, countries.id, countries.region FROM local_network_events LEFT JOIN local_networks ON local_networks.id = local_network_events.local_network_id LEFT JOIN countries ON countries.local_network_id = local_networks.id")
    rows.each do |values|
      local_network_event_id, country_id, region = *values
      execute "UPDATE local_network_events SET country_id=#{country_id.inspect}, region=#{region.inspect} WHERE id=#{local_network_event_id.inspect}"
    end
  end

  def self.down
    remove_column :local_network_events, :country_id
    remove_column :local_network_events, :region
    remove_column :local_network_events, :file_content
  end
end
