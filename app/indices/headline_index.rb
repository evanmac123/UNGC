ThinkingSphinx::Index.define :headline, with: :active_record do
  indexes title

  has published_on
  has created_at
  has :headline_type,                     facet: true

  has country(:id),                       facet: true,      as: :country_id
  has "SELECT headline_id * 18 + 3 as id, topic_id as topic_ids FROM taggings ORDER BY headline_id",
      as: :topic_ids, source: :query, facet: true, multi: true, type: :integer
  has "SELECT headline_id * 18 + 3 as id, issue_id as issue_ids FROM taggings ORDER BY headline_id",
      as: :issue_ids, source: :query, facet: true, multi: true, type: :integer
  has "SELECT headline_id * 18 + 3 as id, sustainable_development_goal_id as sustainable_development_goal_ids FROM taggings ORDER BY headline_id",
      as: :sustainable_development_goal_ids, source: :query, facet: true, multi: true, type: :integer



  where "approval = 'approved'"
end
