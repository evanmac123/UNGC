class RenameIntegEngageAttributes < ActiveRecord::Migration
  def change
    rename_column :due_diligence_reviews, :legal_explanation, :integrity_explanation
    rename_column :due_diligence_reviews, :final_decision, :engagement_rationale
    rename_column :due_diligence_reviews, :decision_maker, :approving_chief
    rename_column :due_diligence_reviews, :declination_reason, :reason_for_decline
  end
end
