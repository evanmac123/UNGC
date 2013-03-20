class AddParticipantManagerContactIdFieldsToCountryAndOrganization < ActiveRecord::Migration
  def self.up
    add_column :countries, :participant_manager_id, :integer
    add_index  :countries, :participant_manager_id

    add_column :organizations, :participant_manager_id, :integer
    add_index  :organizations, :participant_manager_id
  end

  def self.down
    remove_index  :organizations, :participant_manager_id
    remove_column :organizations, :participant_manager_id

    remove_index  :countries, :participant_manager_id
    remove_column :countries, :participant_manager_id
  end
end