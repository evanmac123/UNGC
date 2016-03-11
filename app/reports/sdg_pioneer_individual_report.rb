class SdgPioneerIndividualReport < SimpleReport

  def records
    SdgPioneer::Individual.all
  end

  def headers
    ['Is Participant',
     'Name',
     'Email',
     'Phone',
     'Description of Individual',
     'Other Relevant Information',
     'Supporting Link',
     'Matching SDGs',
     'Local Business Nominating Name',
     'Title',
     'Website URL',
     'Country',
     'Local Network Status',
     'Is Nominated',
     'Nominating Organization',
     'Nominating Individual']
  end

  def row(individual)
    [
      individual.is_participant,
      individual.name,
      individual.email,
      individual.phone,
      individual.description_of_individual,
      individual.other_relevant_info,
      individual.supporting_link,
      individual.matching_sdg_names,
      individual.local_business_nomination_name,
      individual.title,
      individual.website_url,
      individual.country_name,
      individual.local_network_status,
      individual.is_nominated,
      individual.nominating_organization,
      individual.nominating_individual ]
  end

end
