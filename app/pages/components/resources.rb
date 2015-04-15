class Components::Resources
  def initialize(data)
    @data = data
  end

  def data
    resources = @data[:resources]
    return [] unless resources
    ids = resources.map {|r| r[:resource_id] }
    Resource.find ids
  end
end

