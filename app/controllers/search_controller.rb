class SearchController < ApplicationController
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
    
    def results_for_search
      # NOTE: Should the facets chain? ie, top-level: Events: 2 - then you select Events, and we show more facets for Events?
      @facets = Searchable.facets params[:keyword]
      options = {:page => params[:page], :per_page => params[:per_page] || DEFAULTS[:search_results_per_page]}
      if params[:document_type]
        @results = Searchable.faceted_search params[:document_type], params[:keyword], options
      else
        @results = Searchable.search params[:keyword], options
      end
    end
    
    def show_search_form
      @facets = Searchable.facets
      render 'form'
    end

end
