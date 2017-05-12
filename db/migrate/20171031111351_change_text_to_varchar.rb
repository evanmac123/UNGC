class ChangeTextToVarchar < ActiveRecord::Migration
  def change
    change_column :due_diligence_reviews, :world_check_allegations, :string, limit: 5_000
    change_column :due_diligence_reviews, :local_network_input, :string, limit: 5_000
    change_column :due_diligence_reviews, :risk_assessment_comments, :string, limit: 2_000
    change_column :due_diligence_reviews, :legal_explanation, :string, limit: 5_000
    change_column :due_diligence_reviews, :final_decision, :string, limit: 2_000

    change_column :due_diligence_reviews, :decision_maker, :string, limit: 100
    change_column :due_diligence_reviews, :purpose, :string, limit: 100
  end
end
