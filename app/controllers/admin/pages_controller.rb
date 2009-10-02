class Admin::PagesController < ApplicationController
  before_filter :find_page
  
  def edit
    if request.xhr?
      render :json => {
        :url => update_page_url(:format => 'js'),
        :startupMode => @current_version.dynamic_content? ? 'source' : 'wysiwyg',
        :content => @current_version.content
      }
    else
      # NOTE: This may change... maybe? I don't know - jaw
      render :text => 'Not here', :status => 403
    end
  end
  
  def update
    version = @page.new_version(params[:page])
    respond_to do |wants|
      wants.html { redirect_to view_page_url(:path => @page.to_path) }
      wants.js { render :json => { :content => version.content, :version => version.version_number } }
    end
  end
  
  private
  def find_page
    if @page = Page.find_by_id(params[:id])
      @current_version = params[:version].blank? ? @page.active_version : @page.find_version_number(params[:version])
    else
      render :text => 'Not Found', :status => 404
    end
  end
  
end
