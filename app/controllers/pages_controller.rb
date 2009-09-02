class PagesController < ApplicationController
  before_filter :find_content
  layout :determine_layout
  
  def view
  end

  def decorate
    if request.xhr? && true # TODO: can_edit?
      render :update do |page|
        page << "include('/javascripts/admin.js'); include('/ckeditor/ckeditor.js');"
        page['#rightcontent'].prepend render(:partial => 'editor')
      end
    else
      render :text => 'Not here', :status => 403 and return false
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
    @page = Content.for_path(look_for_path)
    render :text => 'Not Found', :status => 404 and return false unless @page
  end
end
