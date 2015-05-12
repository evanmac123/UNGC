class ParticipantSearchPage < ContainerPage

  def hero
    {
      title: {
        title1: "The Compact:",
        title2: "8,0000 Companies + 4,000 Non-Businesses"
      },
      size: :small
    }
  end

  def meta_title
    'Who&rsquo;s Involved'
  end

  def meta_description
    ''
  end

  # TODO add parent, sibling, children menu

  def filters
    [{
      label:        'Type',
      filter:       'organization_types',
      options:      :organization_type_options
    }, {
      label:        'Initiative',
      filter:       'initiatives',
      options:      :initiative_options
    }, {
      label:        'Geography',
      filter:       'countries',
      options:      :country_options
    }, {
      label:        'Sectors',
      filter:       'sectors',
      child_filter: 'sectors',
      options:      :sector_options
    }, {
      label:        'Status',
      filter:       'reporting_status',
      options:      :reporting_status_options
    }]
  end

  def sorting_options
    [{
      field:    :per_page,
      options:  :per_page_options
    }]
  end
end
