class Filters::IssueFilter < Filters::GroupedSearchFilter
  def initialize(selected_parents, selected_children, key: 'issues', excluded: ['none'])
    super(Redesign::IssueTree.new(excluded: excluded), selected_parents)
    self.selected_children = selected_children
    self.label = 'Issue'
    self.key = key
    self.child_key = 'issues'
  end
end
