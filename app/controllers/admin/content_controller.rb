class Admin::ContentController < AdminController
  before_filter :find_content
  
  def edit
    if request.xhr?
      render(:update) { |page| 
        page << %Q{ Editor.create('#{update_content_url(:format => 'js')}', "#{escape_javascript @content.content}"); }
      } and return
    end
  end
  
  def update
    @content.update_attribute(:content, params[:content][:content]) # TODO: Save a new version, wait for approval, etc...
    respond_to do |wants|
      wants.html { redirect_to view_page_url(:path => @content.to_path) }
      wants.js { render :json => { :content => @content.content } }
    end
  end
  
  private
  def find_content
    @content = Content.find_by_id(params[:id])
    render :text => 'Not Found', :status => 404 and return false unless @content
  end
  
end
