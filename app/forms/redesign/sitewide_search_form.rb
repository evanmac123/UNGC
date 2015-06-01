class Redesign::SitewideSearchForm
  include Virtus.model

  attribute :keywords,      String,   default: ''
  attribute :page,          Integer,  default: 1
  attribute :per_page,      Integer,  default: 10
  attribute :document_type, String

  def matched_facets
    @results.facets[:document_type].map do |document_type, count|
      MatchingFacet.new(document_type, count, attributes)
    end
  end

  def execute
    @results = if document_type.present? then faceted_search else keyword_search end
    @results.context[:panes] << ThinkingSphinx::Panes::ExcerptsPane
    @results
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

  MatchingFacet = Struct.new(:document_type, :count, :attributes) do

    def name
      "#{document_type} (#{count})"
    end

    def merge_params_into(params, key)
      facet_params = {
        document_type: document_type,
        page: 1
      }
      params.merge(key => params[key].merge(facet_params))
    end

  end

end
