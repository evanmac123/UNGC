class SectorTree < Tree
  attr_reader :preserved

  def self.load
    new.tree
  end

  def initialize
    sectors = Sector.where.not(parent_id: nil)
      .includes(:parent)
      .select([:id, :parent_id, :name, :preserved])
      .group(:parent_id, :id)
    @preserved = sectors.find_all(&:preserved)
    super(sectors.group_by(&:parent))
  end

end
