class CompositeCachable

  def initialize(*models)
    @models = models.compact
  end

  def updated_at
    @models.map {|m| m.updated_at.try(:utc)}
      .compact
      .max
  end

  def cache_key
    @models.map(&:cache_key).join
  end

end
