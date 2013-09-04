FakePage = Struct.new(:html_code, :title, :path)

class ResourcesController < ApplicationController

  layout 'fullscreen'

  def show
    @resource = Resource.approved.find(params[:id])
  end

  def search
    @leftnav_selected = FakePage.new('resources','About Us','resources')
    @subnav_selected = FakePage.new('search','Tools And Resources','search')
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
