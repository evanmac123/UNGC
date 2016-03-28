class SdgPioneerSubmissionReport < SimpleReport

  def records
    SdgPioneer::Submission.all
  end

  def headers
    [
      'Type',
      'Global goals local business',
      'Name',
      'Title',
      'Email',
      'Phone',
      'Organization name',
      'Exact match',
      'Country',
      'Reason',
      'Accepted Terms',
      'Created at',
    ]
  end

  def row(submission)
    [
      submission.pioneer_type,
      submission.global_goals_activity,
      submission.matching_sdgs,
      submission.name,
      submission.title,
      submission.email,
      submission.phone,
      submission.organization_name,
      submission.organization_name_matched,
      submission.country_name,
      submission.reason_for_being,
      submission.accepts_tou,
      submission.created_at,
      submission.updated_at,
    ]
  end
end
