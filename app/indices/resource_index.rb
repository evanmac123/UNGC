ThinkingSphinx::Index.define :resource, with: :active_record do
  indexes :title,         sortable: true
  indexes :description,   sortable: true
  indexes :year,          sortable: true
  indexes links.title,    sortable: true,   as: :link_title,

  has authors(:id),       sortable: true,   as: :authors_ids
  has principles(:id),    sortable: true,   as: :principle_ids
  has languages(:id),     sortable: true,   as: :language_ids

  where "approval = 'approved'"

  set_property enable_star: true
  set_property min_prefix_len: 4
end
