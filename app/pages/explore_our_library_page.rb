class ExploreOurLibraryPage

  def initialize(container, payload_data)
    @container = container
    @data      = payload_data || {}
  end

  def featured
    resource_ids = @data[:featured] || []
    Resource.find resource_ids
  end

  def [](key)
    # supports page[:title] atm.
    # consider adding a base class/module for these pages
    # once we write a few more
    @data[key.to_sym]
  end

end
