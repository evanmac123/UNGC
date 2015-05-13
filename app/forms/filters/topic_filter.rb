class Filters::TopicFilter < Filters::GroupedSearchFilter
  def initialize(selected_parents, selected_children, key: 'topics')
    super(Redesign::TopicTree.new, selected_parents)
    self.selected_children = selected_children
    self.label = 'Topic'
    self.key = key
    self.child_key = 'topics'
  end
end
