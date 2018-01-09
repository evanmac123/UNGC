class IssueTree < Tree

  def initialize
    super(Issue.where('issues.parent_id > 0')
      .includes(:parent)
      .select([:id, :parent_id, :name])
      .group(:parent_id, :id, :name)
      .group_by do |issue|
        issue.parent
      end)
  end

end
