class Redesign::LibraryController < Redesign::ApplicationController
  layout 'redesign/application'

  def index
    @search = Redesign::LibrarySearchForm.new
    @page = ExploreOurLibrary.load draft?
  end

  def search
    @search = Redesign::LibrarySearchForm.new(params[:page], search_params)
    @results = Resource.search @search.keywords, @search.options
  end

  private

  def search_params
    params[:search]
  end

end
