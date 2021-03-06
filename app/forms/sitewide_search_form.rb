class SitewideSearchForm
  include Virtus.model

  attribute :keywords,      String,   default: ''
  attribute :page,          Integer,  default: 1
  attribute :per_page,      Integer,  default: 10
  attribute :document_type, String

  def facets
    Searchable.facets(escaped_keywords, facet_options)[:document_type].sort.map do |type, count|
      FacetPresenter.new(type, count, type == document_type)
    end
  end

  def execute
    results = case
    when document_type.present?
      faceted_search
    when keywords.present?
      keyword_search
    else
      empty_search
    end

    results.context[:panes] << ThinkingSphinx::Panes::ExcerptsPane

    @results = results
  end

  def clear_facets(params, key)
    params = params.deep_dup

    if params.has_key? key
      params[key].delete(:document_type)
    end

    params
  end

  private

  def faceted_search
    matching_facets = Searchable.facets(escaped_keywords, options)
    matching_facets.for(document_type: document_type)
  end

  def keyword_search
    Searchable.search(escaped_keywords, options)
  end

  def empty_search
    @@empty_search ||= EmptySearch.new
  end

  def escaped_keywords
    SearchEscaper.escape(keywords)
  end

  def facet_options
    {}
  end

  def options
    facet_options.merge(
      page: page,
      per_page: per_page
    )
  end

  FacetPresenter = Struct.new(:document_type, :count, :selected?) do

    def title
      type = I18n.t(document_type.underscore, scope: 'document_types')
      "#{type} (#{count})"
    end

    def merge_with_new_facet(params, key)
      params = params.deep_dup

      facet_params = {document_type: document_type}
      params[key] = params.fetch(key, {}).merge(facet_params)
      params[:page] = 1
      params
    end

    def state
      if selected? then 'active' else 'inactive' end
    end

  end

end
