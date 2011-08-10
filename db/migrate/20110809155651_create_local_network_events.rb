class CreateLocalNetworkEvents < ActiveRecord::Migration
  def self.up
    create_table :local_network_events do |t|
      t.integer :local_network_id

      t.string  :title
      t.text    :description
      t.date    :date
      t.string  :event_type
      t.integer :num_participants
      t.integer :gc_participant_percentage

      t.boolean :stakeholder_company
      t.boolean :stakeholder_sme
      t.boolean :stakeholder_business_association
      t.boolean :stakeholder_labour
      t.boolean :stakeholder_un_agency
      t.boolean :stakeholder_ngo
      t.boolean :stakeholder_foundation
      t.boolean :stakeholder_academic
      t.boolean :stakeholder_government
      t.boolean :stakeholder_media
      t.boolean :stakeholder_others

      t.timestamps
    end
  end

  def self.down
    drop_table :local_network_events
  end
end
