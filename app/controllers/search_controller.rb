class SearchController < ApplicationController

  def search
    @search = SitewideSearchForm.new(search_params)
    @results = @search.execute
    @page = SitewideSearchPage.new
  end

  private

  def search_params
    search_params = params[:search] || ActionController::Parameters.new({})
    search_params
      .permit(:keywords, :document_type)
      .merge(page: page)
  end

  def page
    params.fetch(:page, 1).try(:to_i)
  end

end
