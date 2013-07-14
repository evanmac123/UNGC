class PagesController < ApplicationController
  helper %w{application case_stories cops datetime events local_network navigation news organizations pages participants search sessions signatories signup stakeholders} # needs to be explicit
  before_filter :soft_require_staff_user, :only => :decorate
  before_filter :require_staff_user, :only => :preview
  before_filter :find_content, :except => [:decorate, :preview, :redirect_local_network, :redirect_to_page, :home]
  before_filter :find_content_for_staff, :only => [:decorate, :preview]
  before_filter :page_is_editable, :only => [:preview, :view]

  def home
    if @page = Page.approved_for_path('/index.html')
      @current_version = @page.find_version_number(params[:version]) if params[:version]
      @current_version ||= active_version_of(@page)
    end

    if @page and @current_version
      render :template => template, :layout => 'home'
      cache_page response.body, @page.path unless @page.dynamic_content?
    else
      render :text => 'Not Found', :status => 404
    end
  end

  def view
    render :template => template, :layout => determine_layout
    cache_page response.body, @page.path unless @page.dynamic_content?
  end

  def decorate
    json_to_render = {'editor' => render_to_string(:partial => 'editor')}
    json_to_render['content'] = render_to_string(:template => template, :layout => false) if params[:version]
    render :json => json_to_render
  end

  def preview
    @preview = true
    @current_version.content ||= '<p>[No content]</p>'
    view
  end

  def redirect_to_page
    if params[:page]
      redirect_to params[:page]
    else
      redirect_to root_path
    end
  end

  def redirect_local_network
    if params[:id]
      redirect_to "/NetworksAroundTheWorld/local_network_sheet/#{params[:id]}.html"
    else
      redirect_to root_path
    end
  end

  private

  def determine_layout
    if home_page?
      'home'
    else
      'application'
    end
  end

  def find_content
    if @page = Page.approved_for_path(formatted_request_path)
      @current_version = @page.find_version_number(params[:version]) if params[:version]
      @current_version ||= active_version_of(@page)
    end
    render :text => 'Not Found', :status => 404 unless @page and @current_version
  end

  def find_content_for_staff
    @page = Page.for_path(formatted_request_path)
    @current_version = @page.versions.last
  end

  def active_version_of(page)
    if page.approved?
      page
    else
      page.active_version
    end
  end

  def soft_require_staff_user
    render :text => '  ', :status => 200 unless request.xhr? && staff_user?
  end

  def require_staff_user
    redirect_to root_path unless staff_user?
  end

  def template
    "/pages/#{@current_version.try(:dynamic_content?) ? 'dynamic' : 'static'}"
  end
end
