class Redesign::LibraryController < Redesign::ApplicationController
  layout 'redesign/application'

  def index
    set_current_container :landing, '/redesign/our-library'
    @search = Redesign::LibrarySearchForm.new
    @page = ExploreOurLibraryPage.new(current_container, current_payload_data)
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
