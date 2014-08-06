class AddIndexOnOrganizationsParticipantAndId < ActiveRecord::Migration
  def up
    add_index :organizations, [:participant, :id], :name => 'index_organizations_on_participant_and_id'
  end

  def down
    remove_index :organizations, :name => 'index_organizations_on_participant_and_id'
  end
end
