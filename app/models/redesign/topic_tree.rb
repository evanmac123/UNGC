class Redesign::TopicTree < Redesign::Tree

  def initialize(excluded: ['none'])
    super(Topic.where(parent_id: nil)
      .where.not('name in (?)', excluded)
      .includes(:children)
      .select([:id, :name])
      .map do |parent|
        [parent, parent.children.where.not('name in (?)', excluded)]
      end)
  end

end
