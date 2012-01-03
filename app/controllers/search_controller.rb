class SearchController < ApplicationController
  before_filter :possibly_redirect_to_refine
  before_filter :determine_navigation

  def index
    unless params[:keyword].blank?
      results_for_search
    else
      show_search_form
    end
  end

  def advanced
    show_search_form
  end

  private
    def default_navigation
      DEFAULTS[:search_path]
    end

    def possibly_redirect_to_refine
      redirect_to "#{params[:target]}?keyword=#{params[:keyword]}&commit=search" and return unless params[:target].blank?
    end

    def results_for_search
      keyword = params[:keyword].force_encoding("UTF-8")
      # NOTE: Should the facets chain? ie, top-level: Events: 2 - then you select Events, and we show more facets for Events?
      options = {:page     => params[:page],
                 :per_page => params[:per_page] || DEFAULTS[:search_results_per_page],
                 :star     => true}
      if params[:document_type]
        @results = Searchable.faceted_search params[:document_type], keyword, options
      else
        @results = Searchable.search keyword, options
      end
      @facets = @results && @results.any? ? Searchable.facets(keyword, star: true) : []
    end

    def show_search_form
      # @facets = Searchable.count > 0 ? Searchable.facets : []
      render 'form'
    end

end
