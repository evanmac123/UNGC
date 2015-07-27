class SearchController < Redesign::ApplicationController

  def search
    @search = SitewideSearchForm.new(search_params)
    @results = @search.execute
    @page = SitewideSearchPage.new
  end

  private

  def search_params
    params.fetch(:search, {})
      .permit(:keywords, :document_type)
      .merge(page: page)
  end

  def page
    params.fetch(:page, 1).try(:to_i)
  end

end
