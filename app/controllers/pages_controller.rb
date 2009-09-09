class PagesController < ApplicationController
  before_filter :find_content
  layout :determine_layout
  
  def view
  end

  def decorate
    if request.xhr? && true # TODO: can_edit?
      json_to_render = {'editor' => render_to_string(:partial => 'editor')}
      json_to_render['content'] = render_to_string(:action => 'view', :layout => false) if params[:version]
      render :json => json_to_render
      # render :partial => 'editor' and return
    else
      render :text => 'Not here', :status => 403 
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
      @current_version = params[:version].blank? ? @page.active_version : @page.version_number(params[:version])
    else
      render :text => 'Not Found', :status => 404
    end
  end
end
