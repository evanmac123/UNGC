class PagesController < ApplicationController
  def view
    @page = Content.find_by_path(params[:path].join('/'))
    render :text => 'Not Found', :status => 404 unless @page
  end
end
