class Redesign::IssueTree < Redesign::Tree

  def initialize
    super(Issue.where.not(parent_id: nil)
      .includes(:parent)
      .select([:id, :parent_id, :name])
      .group(:parent_id, :id)
      .group_by do |issue|
        issue.parent
      end)
  end

end
