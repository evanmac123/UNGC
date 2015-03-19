class ExploreOurLibrary

  def self.load(draft = false)
    container = Redesign::Container.landing.find_by!(slug: '/redesign/our-library')
    self.new container, draft
  end

  def initialize(container, draft)
    @container = container

    if @container.present?
      @data = @container.payload(draft).data
    else
      @data = {}
    end
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
