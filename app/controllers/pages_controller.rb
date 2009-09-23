class PagesController < ApplicationController
  before_filter :find_content
  layout :determine_layout
  
  def view
  end

  def decorate
    if request.xhr? && staff_user? # TODO: can_edit?
      json_to_render = {'editor' => render_to_string(:partial => 'editor')}
      json_to_render['content'] = render_to_string(:action => 'view', :layout => false) if params[:version]
      render :json => json_to_render
      # render :partial => 'editor' and return
    else
      render :text => '  ', :status => 200 
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
    if @page = Content.for_path(look_for_path)
      @current_version = @page.version_number(params[:version]) if params[:version]
      @current_version ||= @page.active_version
    else
      render :text => 'Not Found', :status => 404
    end
  end
end
