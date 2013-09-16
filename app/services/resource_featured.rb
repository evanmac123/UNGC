class ResourceFeatured

  def leaders_summit
    find 441,371,451,381,391
  end

  def leaders_summit2
    find 461,401,411,421,421
  end

  def global_compact
    find 229,231,241,240,312
  end

  def human_rights
  end

  def labour
  end

  def summit
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
