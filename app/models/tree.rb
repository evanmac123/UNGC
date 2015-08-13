class Tree

  def initialize(relation)
    @relation = relation
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
