class Redesign::SearchController < Redesign::ApplicationController

  def search
    @search = SitewideSearch.new(search_params)
    @results = @search.execute
    @results.context[:panes] << ThinkingSphinx::Panes::ExcerptsPane
  end

  private

  def search_params
    params.require(:s)
  end

  class SitewideSearch

    def initialize(terms)
      @terms = terms
    end

    def execute
      Redesign::Searchable.search(@terms, {
        page: page,
        per_page: per_page_capped,
        star: true,
        with: options,
        indices: ['searchable_redesign_core'],
        sql: {
          include: [
            # TODO update includes
          ]
        }
      })
    end

    def options
      {}
    end

    def page
      1
    end

    def per_page_capped
      10
    end

  end

end
