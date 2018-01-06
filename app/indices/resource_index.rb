ThinkingSphinx::Index.define :resource, with: :active_record, name: 'resource_old' do
  indexes :title,         sortable: true
  indexes :description,   sortable: true
  indexes :year,          sortable: true
  indexes links.title,    sortable: true,   as: :link_title

  has authors(:id),       facet: true,      as: :authors_ids
  has principles(:id),    facet: true,      as: :principle_ids
  has languages(:id),     facet: true,      as: :language_ids

  where "approval = 'approved'"

  set_property min_prefix_len: 4
end

ThinkingSphinx::Index.define :resource, with: :active_record, name: 'resource_new' do
  indexes :title,         sortable: true
  indexes :description,   sortable: true
  indexes :year,          sortable: true
  indexes links.title,    sortable: true,   as: :link_title

  has :content_type,                      facet: true
  has languages(:id),                     facet: true,      as: :language_ids,                        multi: true
  has "SELECT resource_id * 18 + 6 as id, sector_id as sector_ids FROM taggings ORDER BY resource_id",
      as: :sector_ids, source: :query, facet: true, multi: true, type: :integer
  has "SELECT resource_id * 18 + 6 as id, topic_id as topic_ids FROM taggings ORDER BY resource_id",
      as: :topic_ids, source: :query, facet: true, multi: true, type: :integer
  has "SELECT resource_id * 18 + 6 as id, issue_id as issue_ids FROM taggings ORDER BY resource_id",
      as: :issue_ids, source: :query, facet: true, multi: true, type: :integer
  has "SELECT resource_id * 18 + 6 as id, sustainable_development_goal_id as sustainable_development_goal_ids FROM taggings ORDER BY resource_id",
      as: :sustainable_development_goal_ids, source: :query, facet: true, multi: true, type: :integer

  where "approval = 'approved'"

  set_property min_prefix_len: 4
end
