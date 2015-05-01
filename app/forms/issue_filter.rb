class IssueFilter < GroupedSearchFilter
  def initialize(selected)
    super(Redesign::IssueTree.new, selected)
    self.label = 'Issue'
    self.key = 'issue'
    self.child_key = 'issue'
  end
end
