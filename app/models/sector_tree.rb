class SectorTree < Tree

  def self.load
    new.tree
  end

  def initialize(show_protected: true)
    query = Sector.where.not(parent_id: nil)

    unless show_protected
      query = query.where(preserved: true)
    end

    grouped = query.includes(:parent)
      .select([:id, :parent_id, :name])
      .group(:parent_id, :id)
      .group_by(&:parent)

    super(grouped)
  end

end
