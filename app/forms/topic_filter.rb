class TopicFilter < GroupedSearchFilter
  def initialize(selected)
    super(Redesign::TopicTree.new, selected)
    self.label = 'Topic'
    self.key = 'topic'
    self.child_key = 'topic'
  end
end
