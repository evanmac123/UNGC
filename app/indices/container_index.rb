ThinkingSphinx::Index.define 'container', with: :active_record do
  indexes content_type
  indexes layout

  has issues(:id),        facet: true,      as: :issue_ids,     multi: true
  has topics(:id),        facet: true,      as: :topic_ids,     multi: true
  has "SELECT container_id * 18 + 1 as `id`, sustainable_development_goal_id as `sustainable_development_goal_ids` FROM `taggings` ORDER BY container_id", as: :sustainable_development_goal_ids, source: :query, facet: true, multi: true, type: :integer

  where "public_payload_id is not null"
end
