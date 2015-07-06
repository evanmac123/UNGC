class Redesign::TopicTree < Redesign::Tree

  def initialize
    super(Topic.where(parent_id: nil)
      .includes(:children)
      .select([:id, :name])
      .map do |parent|
        [parent, parent.children]
      end)
  end

end
