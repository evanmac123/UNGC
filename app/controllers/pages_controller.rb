class PagesController < ApplicationController
  layout :determine_layout
  
  def view
    @page = Content.for_path(look_for_path)
    render :text => 'Not Found', :status => 404 unless @page
  end

  private
  
  def determine_layout
    home_page? ? 'home' : 'application'
  end
  
  def home_page?
    current_url == root_path
  end
end
