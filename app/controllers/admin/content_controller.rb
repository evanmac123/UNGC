class Admin::ContentController < AdminController
  before_filter :find_content
  
  def edit
    if request.xhr?
      render :json => {
        :url => update_content_url(:format => 'js'),
        :content => @content.content
      }
    else
      # NOTE: This may change... maybe? I don't know - jaw
      render :text => 'Not here', :status => 403
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
    render :text => 'Not Found', :status => 404 unless @content = Content.find_by_id(params[:id])
  end
  
end
