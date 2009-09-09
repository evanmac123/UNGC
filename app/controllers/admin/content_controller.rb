class Admin::ContentController < AdminController
  before_filter :find_content
  
  def edit
    if request.xhr?
      render :json => {
        :url => update_content_url(:format => 'js'),
        :content => @current_version.content
      }
    else
      # NOTE: This may change... maybe? I don't know - jaw
      render :text => 'Not here', :status => 403
    end
  end
  
  def update
    version = @content.new_version(params[:content])
    respond_to do |wants|
      wants.html { redirect_to view_page_url(:path => @content.to_path) }
      wants.js { render :json => { :content => version.content, :version => version.number } }
    end
  end
  
  private
  def find_content
    if @content = Content.find_by_id(params[:id])
      @current_version = params[:version].blank? ? @content.active_version : @content.version_number(params[:version])
    else
      render :text => 'Not Found', :status => 404
    end
  end
  
end
