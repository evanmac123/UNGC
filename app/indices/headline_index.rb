ThinkingSphinx::Index.define :headline, with: :active_record do
  indexes title

  has published_on
  has created_at
  has :headline_type,                     facet: true

  has country(:id),                       facet: true,      as: :country_id
  has issues(:id),                        facet: true,      as: :issue_ids,    multi: true
  has topics(:id),                        facet: true,      as: :topic_ids,    multi: true
  has sustainable_development_goals(:id), facet: true,      as: :sustainable_development_goal_ids,    multi: true


  where "approval = 'approved'"
end
