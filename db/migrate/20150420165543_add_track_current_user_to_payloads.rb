class AddTrackCurrentUserToPayloads < ActiveRecord::Migration
  def change
    add_column :redesign_payloads, :created_by_id, :integer
    add_column :redesign_payloads, :updated_by_id, :integer
    add_column :redesign_payloads, :approved_by_id, :integer
    add_column :redesign_payloads, :approved_at, :datetime

    add_column :redesign_containers, :has_draft, :boolean, default: true
  end
end
