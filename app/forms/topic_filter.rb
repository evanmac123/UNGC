class TopicFilter < SearchFilter
  def initialize(selected)
    super(Redesign::TopicTree.new, :topic, selected)
    self.label = 'Topic'
    self.parent_key = 'topic'
    self.child_key = 'topic'
  end
end
