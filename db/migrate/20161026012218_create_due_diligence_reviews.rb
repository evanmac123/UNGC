class CreateDueDiligenceReviews < ActiveRecord::Migration
  def change
    create_table :due_diligence_reviews do |t|
      t.references :organization, index: true, foreign_key: true
      t.references :requester, index: true, references: :contacts
      t.integer :state, null: false, default: 0
      t.integer :level_of_engagement
      t.text :world_check_allegations
      t.boolean :included_in_global_marketplace
      t.boolean :subject_to_sanctions
      t.boolean :excluded_by_norwegian_pention_fund
      t.boolean :involved_in_landmines
      t.boolean :involved_in_tobacco
      t.integer :esg_score
      t.integer :highest_controversy_level
      t.string :incidents_low
      t.string :incidents_moderate
      t.string :incidents_significant
      t.string :incidents_high
      t.string :incidents_severe
      t.integer :rep_risk_peak
      t.integer :rep_risk_current
      t.string :rep_risk_news_stats
      t.integer :rep_risk_severity_of_news
      t.text :local_network_input
      t.boolean :requires_local_network_input

      t.text :risk_assessment_comments


      t.string :legal_recommendation
      t.text :legal_explanation
      t.boolean :refer_to_integrity_commitee

      t.text :integrity_decision
      t.text :integrity_action_points
      t.text :final_decision
      t.string :decision_maker

      t.timestamps null: false
    end

    add_foreign_key :due_diligence_reviews, :contacts, column: :requester_id
  end
end
