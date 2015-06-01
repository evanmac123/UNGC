class Redesign::SearchController < Redesign::ApplicationController

  def search
    @search = SitewideSearch.new(search_params)
    @results = @search.execute
  end

  private

  def search_params
    params.require(:search).permit(:keywords)
  end

  class SitewideSearch
    include Virtus.model

    attribute :keywords,      String,   default: ''
    attribute :page,          Integer,  default: 1
    attribute :per_page,      Integer,  default: 10
    attribute :document_type, String

    def execute
      results = if document_type.present?
        matching_facets = Redesign::Searchable.facets(escaped_keywords, options)
        matching_facets.for(document_type: document_type)
      else
        Redesign::Searchable.search(escaped_keywords, sphinx_options)
      end
      results.context[:panes] << ThinkingSphinx::Panes::ExcerptsPane
      results
    end

    def escaped_keywords
      Riddle::Query.escape(keywords)
    end

    def sphinx_options
      {
        page: page,
        per_page: per_page,
        star: true,
        with: options,
        indices: ['searchable_redesign_core']
      }
    end

    def options
      {}
    end

  end

end
