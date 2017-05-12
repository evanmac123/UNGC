class MoreModelTweaks < ActiveRecord::Migration
  def change
    remove_columns :due_diligence_reviews,:incidents_low,
                   :incidents_moderate,
                   :incidents_significant,
                   :incidents_high,
                   :incidents_severe,
                   :rep_risk_news_stats,
                   :with_reservation

    rename_column :due_diligence_reviews, :excluded_by_norwegian_pention_fund,
                  :excluded_by_norwegian_pension_fund

    rename_column :due_diligence_reviews, :legal_recommendation, :additional_research
    change_column :due_diligence_reviews, :additional_research, :text

    rename_column :due_diligence_reviews, :risk_assessment_comments,
                  :analysis_comments
    change_column :due_diligence_reviews, :analysis_comments, :text

    add_column :due_diligence_reviews, :subject_to_dialog_facilitation, :boolean

    change_column :due_diligence_reviews, :legal_explanation, :string, limit: 1_000

    add_column :due_diligence_reviews, :with_reservation, :integer

    change_column :due_diligence_reviews, :local_network_input, :string, limit: 2_000
    change_column :due_diligence_reviews, :world_check_allegations, :string, limit: 2_000
  end
end
