class Components::Resources
  def initialize(data)
    @data = data
  end

  def data
    resources = @data[:resources] || []
    resource_ids = resources.map{|r| r[:resource_id] }.reject(&:nil?)
    return [] if resource_ids.empty?
    Resource.where('id IN (?)', resource_ids).order("field(id, #{resource_ids.join(',')})")
  end
end

