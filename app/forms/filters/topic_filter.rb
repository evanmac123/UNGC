class Filters::TopicFilter < Filters::GroupedSearchFilter
  def initialize(selected_parents, selected_children, key: 'topics', excluded: ['none'])
    super(Redesign::TopicTree.new(excluded: excluded), selected_parents)
    self.selected_children = selected_children
    self.label = 'Topic'
    self.key = key
    self.child_key = 'topics'
  end
end
