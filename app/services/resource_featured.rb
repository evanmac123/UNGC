class ResourceFeatured
  include ResourcesHelper

  def new_resources
    find_resources [1151, 1131, 1181, 1171, 1051]
  end

  def new_resources_2
    find_resources [1101, 841, 791, 411, 781]
  end

  def global_compact
    find_resources [229,231,241,240,441]
  end

  def cop
    find_resources [305,306,531,49,154]
  end

  def local_networks
    find_resources [312,310,431,491,177]
  end
  
  def human_rights
    find_resources [2,22,9,341,3]
  end

  def labour
    find_resources [261,75,79,104,89]
  end

  def environment
    find_resources [118,481,138,501,139]
  end

  def anti_corruption
    find_resources [162,154,152,411,771]
  end

  def business_peace
    find_resources [381,491,281,165,262]
  end

  def development
    find_resources [179,320,173,391,174]
  end

  def financial_markets
    find_resources [811,210,211,215,209]
  end

  def partnerships
    find_resources [841,361,200,201,202]
  end

  def supply_chain
    find_resources [207,205,421,791,204]
  end

end