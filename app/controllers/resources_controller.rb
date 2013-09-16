FakePage = Struct.new(:html_code, :title, :path)

class ResourcesController < ApplicationController

  layout 'fullscreen'

  def show
    @resource = Resource.approved.find(params[:id])
    @resource.increment_views! if @resource
    @current_section = FakePage.new('resources','About Us','/AboutTheGC')
    @leftnav_selected = FakePage.new('tools_resources','Tools and Resources','/resources')
    @subnav_selected = FakePage.new('tools_resources', "Resource Detail",'')
  end

  def index
    @leftnav_selected = FakePage.new('resources','About Us','/AboutTheGC')
    @subnav_selected = FakePage.new('tools_resources','Tools And Resources','/resources')

    @featured = ResourceFeatured.new
    if params[:commit].blank?
      @authors = Author.for_approved_resources
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

  def link_views
    ResourceLink.find(params[:resource_link_id]).increment_views!
    respond_to do |format|
      format.js { render nothing: true }
    end
  end
end
