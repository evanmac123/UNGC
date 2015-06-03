class Redesign::SitewideSearchForm
  include Virtus.model

  attribute :keywords,      String,   default: ''
  attribute :page,          Integer,  default: 1
  attribute :per_page,      Integer,  default: 10
  attribute :document_type, String

  def self.submit(params)
    if params.any?
      new(params)
    else
      NullSearch.new(params)
    end
  end

  def facets
    Redesign::Searchable.facets(escaped_keywords, options)[:document_type].sort.map do |type, count|
      MatchingFacet.new(type, count, type == document_type)
    end
  end

  def execute
    @results = if document_type.present?
      faceted_search
    else
      keyword_search
    end

    @results.context[:panes] << ThinkingSphinx::Panes::ExcerptsPane
    @results
  end

  def clear_facets(params, key)
    if params.has_key? key
      params[key].delete(:document_type)
    end

    params
  end

  private

  def faceted_search
    matching_facets = Redesign::Searchable.facets(escaped_keywords, options)
    matching_facets.for(document_type: document_type)
  end

  def keyword_search
    Redesign::Searchable.search(escaped_keywords, options)
  end

  def escaped_keywords
    Riddle::Query.escape(keywords)
  end

  def options
    {
      page: page,
      per_page: per_page,
      star: true,
      indices: ['searchable_redesign_core']
    }
  end

  MatchingFacet = Struct.new(:document_type, :count, :selected?) do

    def name
      "#{document_type} (#{count})"
    end

    def merge_params_into(params, key)
      facet_params = {
        document_type: document_type,
        page: 1
      }

      params[key] = params.fetch(key, {}).merge(facet_params)
    end

    def state
      if selected? then 'active' else 'inactive' end
    end

  end

  NullSearch = Struct.new(:params) do

    def facets
      self
    end

    def execute
      self
    end

    def clear_facets(params, _)
      params
    end

    def keywords
      nil
    end

    def none?
      false
    end

    def any?
      false
    end

    def total_pages
      0
    end

  end

end
