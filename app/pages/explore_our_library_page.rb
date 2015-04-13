class ExploreOurLibraryPage < ContainerPage
  def featured
    resource_ids = Array(@data[:featured]).map { |r| r[:resource_id] }
    Resource.where('id IN (?)', resource_ids).order("field(id, #{resource_ids.join(',')})")
  end

  def [](key)
    # supports page[:title] atm.
    # consider adding a base class/module for these pages
    # once we write a few more
    @data[key.to_sym]
  end

end
