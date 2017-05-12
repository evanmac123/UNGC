class RemoveIntegrityChecksFromDueDiligenceReviews < ActiveRecord::Migration
  def change
    remove_column :due_diligence_reviews, :integrity_decision, :text
    remove_column :due_diligence_reviews, :integrity_action_points, :text
    remove_column :due_diligence_reviews, :refer_to_integrity_commitee, :boolean
  end
end
