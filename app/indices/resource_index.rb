ThinkingSphinx::Index.define :resource, :with => :active_record do
  indexes :title, :sortable => true
  indexes :description, :sortable => true
  indexes :year, :sortable => true
  indexes links.title, :as => "link_title", :sortable => true

  has authors(:id),     :as => :authors_ids, :facet => true
  has principles(:id),     :as => :principle_ids, :facet => true
  has languages(:id), :as => :language_ids, facet: true

  where "approval = 'approved'"

  set_property :enable_star => true
  set_property :min_prefix_len => 4
end
