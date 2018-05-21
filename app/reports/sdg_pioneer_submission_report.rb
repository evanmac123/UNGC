class SdgPioneerSubmissionReport < SimpleReport

  def records
    date  = Date.new(2018,05,03)
    SdgPioneer::Submission.where("created_at >= ?", date)
  end

  def headers
    [
      'Type',
      'Company Success',
      'SDG Innovations',
      'Awareness and Mobilization',
      'Ten Principles',
      'Matching SDGs',
      'Name',
      'Title',
      'Email',
      'Phone',
      'Organization name',
      'Exact match',
      'Country',
      'Accepted Terms',
      'Created at',
    ]
  end

  def row(submission)
    [
      submission.pioneer_type,
      submission.company_success,
      submission.innovative_sdgs,
      submission.awareness_and_mobilize,
      submission.ten_principles,
      submission.matching_sdgs,
      submission.name,
      submission.title,
      submission.email,
      submission.phone,
      submission.organization_name,
      submission.organization_name_matched,
      submission.country_name,
      submission.accepts_tou,
      submission.created_at,
    ]
  end
end
