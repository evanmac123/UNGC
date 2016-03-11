class SdgPioneerBusinessReport < SimpleReport

  def records
    SdgPioneer::Business.all
  end

  def header
    ['Organization Name',
     'Is Participant',
     'Contact Person Name',
     'Contact Person Title',
     'Contact Person Email',
     'Contact Person Phone',
     'Website URL',
     'Country',
     'Local Network Status',
     'Positive Outcomes',
     'Matching SDGs'
     'Other Relevant Information',
     'Local Business Name'
     'Is Nominated',
     'Nominating Organization',
     'Nominating Individual']
  end

  def row(business)
    [ business.organization_name,
      business.is_participant,
      business.contact_person_name,
      business.contact_person_title,
      business.contact_person_email,
      business.contact_person_phone,
      business.website_url,
      business.country_name,
      business.local_network_status,
      business.positive_outcomes,
      business.matching_sdgs
      business.other_relevant_info,
      business.local_business_name,
      business.is_nominated,
      business.nominating_organization,
      business.nominating_individual ]
  end
end
