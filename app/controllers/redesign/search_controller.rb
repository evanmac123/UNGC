class Redesign::SearchController < Redesign::ApplicationController

  def search
    @search = Redesign::SitewideSearchForm.submit(search_params)
    @results = @search.execute
  end

  private

  def search_params
    params.fetch(:search, {}).permit(:keywords, :document_type)
  end

end
