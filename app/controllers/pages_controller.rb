class PagesController < ApplicationController
  before_filter :soft_require_staff_user, :only => :decorate
  before_filter :find_content
  layout :determine_layout
  
  def view
  end

  def decorate
    json_to_render = {'editor' => render_to_string(:partial => 'editor')}
    json_to_render['content'] = render_to_string(:action => 'view', :layout => false) if params[:version]
    render :json => json_to_render
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
    if @page = Content.for_path(look_for_path)
      @current_version = @page.version_number(params[:version]) if params[:version]
      @current_version ||= @page.active_version
    else
      render :text => 'Not Found', :status => 404
    end
  end
  
  def soft_require_staff_user
    render :text => '  ', :status => 200 unless request.xhr? && staff_user?
  end
end
