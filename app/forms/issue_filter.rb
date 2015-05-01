class IssueFilter < SearchFilter
  def initialize(label = 'Issues', type = :issue, parent_key = 'issues', child_key = 'issues')
    tree = Redesign::IssueTree.new
    super(tree, type, label, parent_key, child_key)
  end
end
