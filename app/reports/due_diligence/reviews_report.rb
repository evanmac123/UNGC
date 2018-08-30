class DueDiligence::ReviewsReport < SimpleReport

  def records
    DueDiligence::Review.joins(:organization, :requester).order(:created_at)
  end

  def render_output
    self.render_xls_in_batches
  end

  def headers
    [ 'Review ID',
      'Organization ID',
      'Organization Name',
      'Requester ID',
      'Requester Name',
      'Requester Username',
      'Requester Email',
      'State',
      'Level of Engagement',
      'World Check Allegations',
      'Included in Global Marketplace',
      'Subject to Sanctions',
      'Excluded by Norwegian Pention Fund',
      'Involved In Landmines',
      'Involved in Tobacco',
      'ESG Score',
      'Highest Controversy Level',
      'Incidents Low',
      'Incidents Moderate',
      'Incidents Significant',
      'Incidents High',
      'Incidents Severe',
      'Rep Risk Peak',
      'Rep Risk Current',
      'Rep Risk News Stats',
      'Rep Risk Severity of News',
      'Local Network Input',
      'Requires Local Network Input',
      'Risk Assessment Comments',
      'Integrity Explanation',
      'Engagement Rationale',
      'Chief',
      'Created At',
      'Updated At',
      'Refer to Integrity Committee',
      'Integrity Action Points',
      'Integrity Decision'
    ]
  end

  def row(record)
    [ record.id,
      record.organization_id,
      record.organization.name,
      record.requester_id,
      record.requester.name,
      record.requester.username,
      record.requester.email,
      record.state,
      record.level_of_engagement,
      record.world_check_allegations,
      record.included_in_global_marketplace,
      record.subject_to_sanctions,
      record.excluded_by_norwegian_pension_fund,
      record.involved_in_landmines,
      record.involved_in_tobacco,
      record.esg_score,
      record.highest_controversy_level,
      record.rep_risk_peak,
      record.rep_risk_current,
      record.rep_risk_severity_of_news,
      record.local_network_input,
      record.requires_local_network_input,
      record.analysis_comments,
      record.additional_research,
      record.integrity_explanation,
      record.engagement_rationale,
      record.approving_chief,
      record.created_at,
      record.updated_at,
      record.integrity_action_points,
      record.integrity_decision
    ]
  end
end
