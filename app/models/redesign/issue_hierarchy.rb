class Redesign::IssueHierarchy

  def initialize
    @relation = Issue.where(type: nil)
      .includes(:issue_area)
      .select([:id, :issue_area_id, :name])
      .group(:issue_area_id, :id)
      .group_by do |issue|
        issue.issue_area
      end
  end

  def each(&block)
    @relation.each(&block)
  end

  def map(&block)
    @relation.map(&block)
  end

  def tree
    map do |parent, children|
      [
        parent.name,
        children.map do |topic|
          [topic.name, topic.id]
        end
      ]
    end
  end

end
