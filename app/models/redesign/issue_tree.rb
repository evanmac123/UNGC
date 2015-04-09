class Redesign::IssueTree < Redesign::Tree

  def initialize
    super(Issue.where(type: nil)
      .includes(:issue_area)
      .select([:id, :issue_area_id, :name])
      .group(:issue_area_id, :id)
      .group_by do |issue|
        issue.issue_area
      end)
  end

end
