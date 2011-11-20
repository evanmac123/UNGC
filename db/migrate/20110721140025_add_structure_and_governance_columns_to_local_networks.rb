class AddStructureAndGovernanceColumnsToLocalNetworks < ActiveRecord::Migration
  def self.up
    add_column :local_networks, :sg_global_compact_launch_date,                       :date
    add_column :local_networks, :sg_local_network_launch_date,                        :date
    add_column :local_networks, :sg_annual_meeting_appointments,                      :boolean
    add_column :local_networks, :sg_annual_meeting_appointments_file_id,              :integer
    add_column :local_networks, :sg_selected_appointees_local_network_representative, :boolean
    add_column :local_networks, :sg_selected_appointees_steering_committee,           :boolean
    add_column :local_networks, :sg_selected_appointees_contact_point,                :boolean
    add_column :local_networks, :sg_established_as_a_legal_entity,                    :boolean
    add_column :local_networks, :sg_established_as_a_legal_entity_file_id,            :integer
  end

  def self.down
    remove_column :local_networks, :sg_global_compact_launch_date
    remove_column :local_networks, :sg_local_network_launch_date
    remove_column :local_networks, :sg_annual_meeting_appointments
    remove_column :local_networks, :sg_annual_meeting_appointments_file_id
    remove_column :local_networks, :sg_selected_appointees_local_network_representative
    remove_column :local_networks, :sg_selected_appointees_steering_committee
    remove_column :local_networks, :sg_selected_appointees_contact_point
    remove_column :local_networks, :sg_established_as_a_legal_entity
    remove_column :local_networks, :sg_established_as_a_legal_entity_file_id
  end
end
