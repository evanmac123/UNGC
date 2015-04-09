class Redesign::TopicTree < Redesign::Tree

  def initialize
    super(Topic.where.not(parent_id: nil)
      .includes(:parent)
      .select([:id, :parent_id, :name])
      .group(:parent_id, :id)
      .group_by do |topic|
        topic.parent
      end)
  end

end
