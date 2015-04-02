class Redesign::TopicHierarchy

  def initialize
    @relation = Topic.where.not(parent_id: nil)
      .includes(:parent)
      .select([:id, :parent_id, :name])
      .group(:parent_id, :id)
      .group_by do |topic|
        topic.parent
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
