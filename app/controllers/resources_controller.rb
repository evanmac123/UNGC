FakePage = Struct.new(:html_code, :title, :path)

class ResourcesController < ApplicationController

  layout 'fullscreen'

  def show
    @resource = Resource.approved.find(params[:id])
  end

  def index
    redirect_to resources_search_path
  end

  def search
    @leftnav_selected = FakePage.new('resources','About Us','search')
    @subnav_selected = FakePage.new('tools_resources','Tools And Resources','search')

    @featured = ResourceFeatured.new
    if params[:commit].blank?
      @authors = Author.scoped
      @topics = Principle.topics_menu
      @search = ResourceSearch.new params[:resource_search]
      render :action => 'index'
    else
      @search = ResourceSearch.new params[:resource_search]
      @search.page = params[:page]
      @search.per_page = params[:per_page]
      @search.order = params[:order]
      @results = @search.get_search_results
      render :action => 'results'
    end
  end
end
