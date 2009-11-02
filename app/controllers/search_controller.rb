class SearchController < ApplicationController
  def index
    @results = Searchable.search params[:keyword], :page => params[:page], :per_page => params[:per_page] || DEFAULTS[:search_results_per_page]
  end

  def advanced
  end

end
