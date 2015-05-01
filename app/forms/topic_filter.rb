class TopicFilter < SearchFilter
  def initialize(label = 'Topics', type = :topic, parent_key = 'topics', child_key = 'topics')
    tree = Redesign::TopicTree.new
    super(tree, type, label, parent_key, child_key)
  end
end
