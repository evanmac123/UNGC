class Components::Resources
  def initialize(data)
    @data = data
  end

  def data
    resources = @data[:resources] || []
    resource_ids = resources.map{|r| r[:resource_id] }.reject(&:nil?)
    return [] if resource_ids.empty?
    Resource
        .where(id: resource_ids)
        .order(AnsiSqlHelper.fields_as_case(:id, resource_ids, resource_ids.max + 1))

  end
end
