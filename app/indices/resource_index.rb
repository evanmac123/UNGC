ThinkingSphinx::Index.define :resource, with: :active_record do
  indexes :title,         sortable: true
  indexes :description,   sortable: true
  indexes :year,          sortable: true
  indexes links.title,    sortable: true,   as: :link_title

  has authors(:id),       facet: true,      as: :authors_ids
  has principles(:id),    facet: true,      as: :principle_ids
  has languages(:id),     facet: true,      as: :language_ids
  has :content_type,      facet: true
  has sectors(:id),       facet: true,      as: :sector_ids
  has issues(:id),        facet: true,      as: :issue_ids
  has issue_areas(:id),   facet: true,      as: :issue_area_ids

  where "approval = 'approved'"

  set_property enable_star: true
  set_property min_prefix_len: 4
end
