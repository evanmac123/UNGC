class ResourceFeatured

  def featured
    find 1,2,3,4,5
  end

  def global_compact
    find 6,7,8,9,10
  end

  def human_rights
    find 11,12,13,14,15
  end

  def labour
  end

  def environment
  end

  def anti_corruption
  end

  def development
  end

  def local_networks
  end

  def business_for_peace
  end

  def financial_markets
  end

  def communication_on_progress
  end

private
  def find(*ids)
    Resource.find ids
  end

end
