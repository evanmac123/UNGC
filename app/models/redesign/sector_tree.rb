class Redesign::SectorTree < Redesign::Tree

  def initialize
    super(Sector.where.not(parent_id: nil)
      .includes(:parent)
      .select([:id, :parent_id, :name])
      .group(:parent_id, :id)
      .group_by do |sector|
        parent = sector.parent
      end)
  end
end



