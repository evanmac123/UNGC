class IssueFilter < SearchFilter
  def initialize(selected)
    super(Redesign::IssueTree.new, :issue, selected)
    self.label = 'Issue'
    self.parent_key = 'issue'
    self.child_key = 'issue'
  end
end
