class Redesign::SearchController < Redesign::ApplicationController

  def search
    @search = Redesign::SitewideSearchForm.new(search_params)
    @results = @search.execute
    @page = SitewideSearchPage.new
  end

  private

  def search_params
    params.fetch(:search, {}).permit(:keywords, :document_type)
  end

end