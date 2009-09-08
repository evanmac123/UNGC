class PagesController < ApplicationController
  before_filter :find_content
  layout :determine_layout
  
  def view
  end

  def decorate
    if request.xhr? && false # TODO: can_edit?
      render :partial => 'editor' and return
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
    render :text => 'Not Found', :status => 404 unless @page = Content.for_path(look_for_path)
  end
end
