class RemoveDefaultFromSubmissionsIsParticipant < ActiveRecord::Migration
  def change
    change_column :sdg_pioneer_submissions, :is_participant, :boolean, null: true, default: nil
  end
end
