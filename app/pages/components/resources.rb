class Components::Resources
  def initialize(data)
    @data = data
  end

  def data
    ids = @data[:resources].map {|r| r[:resource_id] }
    Resource.find ids
  end
end

