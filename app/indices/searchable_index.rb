ThinkingSphinx::Index.define :searchable, :with => :active_record, name: :searchable do
  indexes title
  indexes content
  indexes document_type, :as => :document_type, :facet => true
  has url, last_indexed_at
  set_property :delta => true # TODO: Switch this to :delayed once we have DJ working
  set_property :field_weights => {"title" => 100}

  set_property :enable_star => true
  set_property :min_prefix_len => 4
end

ThinkingSphinx::Index.define :'redesign/searchable', :with => :active_record, name: :searchable_redesign do
  indexes title
  indexes content
  indexes meta
  indexes document_type, :as => :document_type, :facet => true

  set_property :delta => true # TODO: Switch this to :delayed once we have DJ working
  set_property :field_weights => {"title" => 100}

  set_property :enable_star => true
  set_property :min_prefix_len => 4
end

