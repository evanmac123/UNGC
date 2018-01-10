class ExploreOurLibraryPage < ContainerPage
  def featured
    resource_ids = Array(@data[:featured]).map { |r| r[:resource_id] }
    return [] if resource_ids.blank?

    Resource
        .where(id: resource_ids)
        .order(AnsiSqlHelper.fields_as_case(:id, resource_ids))
  end

  def [](key)
    # supports page[:title] atm.
    # consider adding a base class/module for these pages
    # once we write a few more
    @data[key.to_sym]
  end

  def hero
    (@data[:hero] || {}).merge({size: 'small'})
  end

  def filters
    [{
      label:        'Issues',
      filter:       'issue_areas',
      child_filter: 'issues',
      options:      :issue_options
    }, {
      label:        'Topics',
      filter:       'topic_groups',
      child_filter: 'topics',
      options:      :topic_options
    }, {
      label:        'Languages',
      filter:       'languages',
      options:      :language_options
    }, {
      label:        'Sectors',
      filter:       'sector_groups',
      child_filter: 'sectors',
      options:      :sector_options
    }]
  end

  def sorting_options
    [{
      field:    :content_type,
      options:  :type_options,
      label:    'Type'
    },{
      field:    :sort_field,
      options:  :sort_options,
      label:    'Sort by'
    }]
  end
end
