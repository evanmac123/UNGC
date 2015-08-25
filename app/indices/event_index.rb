ThinkingSphinx::Index.define :event, :with => :active_record do
  indexes title

  has :is_online,           facet: true
  has :is_invitation_only,  facet: true
  has :starts_at,           facet: true
  has :ends_at,             facet: true

  has country(:id),         facet: true,      as: :country_id
  has issues(:id),          facet: true,      as: :issue_ids,    multi: true
  has topics(:id),          facet: true,      as: :topic_ids,    multi: true
  has sustainable_development_goals(:id),          facet: true,      as: :sustainable_development_goal_ids,    multi: true

  where "approval = 'approved'"
end
