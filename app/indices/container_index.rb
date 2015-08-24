ThinkingSphinx::Index.define 'container', with: :active_record do
  indexes content_type
  indexes layout

  has issues(:id),        facet: true,      as: :issue_ids,     multi: true
  has topics(:id),        facet: true,      as: :topic_ids,     multi: true

  where "public_payload_id is not null"
end
