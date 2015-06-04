class Redesign::LibraryController < Redesign::ApplicationController

  def index
    set_current_container :library, '/library'
    @search = Redesign::LibrarySearchForm.new
    @page = create_page
    @results = []
  end

  def show
    set_current_container_by_path('/library')
    resource = Resource.
      includes([issues: [:parent], sectors: [:parent], topics: [:parent], links: [:language]])
      .find(params[:id])
    @resource = LibraryDetailPresenter.new(resource)
    @page = LibraryDetailPage.new(current_container, resource)
  end

  def search
    set_current_container :library, '/library'
    @search = Redesign::LibrarySearchForm.new(page, search_params)
    @page = create_page
    @results = @search.execute
  end

  private

  def search_params
    params.fetch(:search, {}).permit(
      :keywords,
      :content_type,
      :sort_field,
      issue_areas: [],
      issues: [],
      topic_groups: [],
      topics: [],
      languages: [],
      sector_groups: [],
      sectors: []
    )
  end

  def page
    params.fetch(:page, 1)
  end

  def create_page
    ExploreOurLibraryPage.new(current_container, current_payload_data)
  end

end
