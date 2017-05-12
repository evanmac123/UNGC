class ChangeDueDiligenceReviewStateToString < ActiveRecord::Migration
  def change
    change_column :due_diligence_reviews, :state, :string, null: false, index: true
    change_column_default :due_diligence_reviews, :state, nil
  end
end
