class LibraryController < ApplicationController

  def index
    set_current_container :library, '/library'
    @search = LibrarySearchForm.new
    @page = create_page
    @results = []
  end

  def show
    show_resource do |resource|
      resource.find(params[:id]).tap { |r| r.increment_views! if r }
    end
  end

  def link_views
    ResourceLink.find(params[:resource_link_id]).increment_views!
    respond_to do |format|
      format.js { render nothing: true }
    end
  end

  def blueprint_for_corporate_sustainability
    show_resource do |resource|
      resource.find_by!(title: "Blueprint for Corporate Sustainability Leadership within the Global Compact")
    end
  end

  def advanced_cop_submission_guide
    show_resource do |resource|
      resource.find_by!(title: "GC Advanced COP Submission Guide")
    end
  end

  def search
    set_current_container :library, '/library'
    @search = LibrarySearchForm.new(page, search_params)
    @page = create_page
    @results = @search.execute
  end

  private

  def show_resource
    set_current_container_by_path('/library')
    resource = Resource.includes([
      issues: [:parent],
      sectors: [:parent],
      topics: [:parent],
      links: [:language]
    ])
    resource = yield(resource)
    @resource = LibraryDetailPresenter.new(resource)
    @page = LibraryDetailPage.new(current_container, resource)
    render :show
  end

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
    params.fetch(:page, 1).try(:to_i)
  end

  def create_page
    ExploreOurLibraryPage.new(current_container, current_payload_data)
  end

end
