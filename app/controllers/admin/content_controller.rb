class Admin::ContentController < AdminController
  before_filter :find_content
  
  def edit
    if request.xhr?
      render(:update) { |page| 
        page << %Q{ Editor.create("#{escape_javascript @content.content}"); }
      } and return
    end
  end
  
  private
  def find_content
    @content = Content.find_by_id(params[:id])
    render :text => 'Not Found', :status => 404 and return false unless @content
  end
  
end
