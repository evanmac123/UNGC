ThinkingSphinx::Index.define :event, :with => :active_record do
  indexes title

  has :is_online,           facet: true
  has :is_invitation_only,  facet: true
  has :is_academy,          facet: true
  has :starts_at,           facet: true
  has :ends_at,             facet: true

  has country(:id),         facet: true,      as: :country_id
  has "SELECT event_id * 18 + 2 as id, topic_id as topic_ids FROM taggings ORDER BY event_id",
      as: :topic_ids, source: :query, facet: true, multi: true, type: :integer
  has "SELECT event_id * 18 + 2 as id, issue_id as issue_ids FROM taggings ORDER BY event_id",
      as: :issue_ids, source: :query, facet: true, multi: true, type: :integer
  has "SELECT event_id * 18 + 2 as id, sustainable_development_goal_id as sustainable_development_goal_ids FROM taggings ORDER BY event_id",
      as: :sustainable_development_goal_ids, source: :query, facet: true, multi: true, type: :integer

  where "approval = 'approved'"
end
