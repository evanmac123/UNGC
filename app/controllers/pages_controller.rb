class PagesController < ApplicationController
  helper %w{application case_stories cops datetime events local_network navigation news organizations pages participants search sessions signatories signup stakeholders} # needs to be explicit
  before_filter :soft_require_staff_user, :only => :decorate
  before_filter :find_content, :except => [:redirect_local_network]
  before_filter :page_is_editable, :only => :view
  # layout :determine_layout
  
  def view
    render :template => template, :layout => determine_layout
  end

  def decorate
    json_to_render = {'editor' => render_to_string(:partial => 'editor')}
    json_to_render['content'] = render_to_string(:template => template, :layout => false) if params[:version]
    render :json => json_to_render
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
  
  def template
    "/pages/#{@current_version.try(:dynamic_content?) ? 'dynamic' : 'static'}.html.haml"
  end
end
