ThinkingSphinx::Index.define 'redesign/container', with: :active_record do
  has issues(:id),        facet: true,      as: :issue_ids,     multi: true
  has topics(:id),        facet: true,      as: :topic_ids,     multi: true

  where "public_payload_id is not null"

  set_property enable_star: true
  set_property min_prefix_len: 4
end
