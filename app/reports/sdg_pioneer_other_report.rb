class SdgPioneerOtherReport < SimpleReport

  def records
    SdgPioneer::Other.all
  end

  def headers
    [ 'Submitter Name',
      'Submitter Place of Work',
      'Submitter Email',
      'Nominee Name',
      'Nominee Email',
      'Nominee Phone',
      'Nominee Work Place',
      'Organization Type',
      'Submitter Job Title',
      'Submitter Phone',
      'Nominee Title',
      'Why Nominate',
      'SDG Pioneer Role' ]
  end

  def row(business)
    [ business.submitter_name,
      business.submitter_place_of_work,
      business.submitter_email,
      business.nominee_name,
      business.nominee_email,
      business.nominee_phone,
      business.nominee_work_place,
      business.organization_type,
      business.submitter_job_title,
      business.submitter_phone,
      business.nominee_title,
      business.why_nominate,
      business.sdg_pioneer_role ]
  end

end
