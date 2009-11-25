class Admin::PagesController < AdminController
  before_filter :find_page, :only => [:approve, :edit, :delete, :destroy, :meta, :revoke, :update]
  before_filter :ckeditor, :only => [:new, :create, :edit, :update]

  def index
    @section = 'normal'
  end

  def pending
    @section = 'pending'
    render action: 'index'
  end

  def new
    defaults = {:path => (params[:section] || '/') + 'untitled.html'}
    @page = Page.new defaults.merge(params[:page] || {})
  end

  def create
    @page = Page.new params[:page]
    if @page.save
      flash[:notice] = "Page successfully created"
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def destroy
    @page.destroy
    redirect_to :action => 'index'
  end

  def approve
    @page.as_user(current_user).approve!
    redirect_to :action => 'index'
  end

  def revoke
    @page.as_user(current_user).revoke!
    redirect_to :action => 'index'
  end
  
  def meta
    
  end
  
  def edit
    if request.xhr?
      render :json => {
        :url => update_page_url(:format => 'js'),
        :startupMode => @current_version.dynamic_content? ? 'source' : 'wysiwyg',
        :content => @current_version.content
      }
      return
    end
  end
  
  def update
    if params[:content] # this is the live editor
      @version = @page.update_pending_or_new_version(params[:content])
      respond_to do |wants|
        wants.html { redirect_to view_page_url(:path => @page.to_path) }
        wants.js { render :json => { :content => @version.content, :version => @version.version_number } }
      end
      return
    else
      @version = @page.update_pending_or_new_version(params[:page])
      redirect_to edit_admin_page_path(:id => @version)
      return
    end
  end

  def find_by_path_and_redirect_to_latest
    page = Page.all_versions_of(params[:path]).last
    redirect_to edit_admin_page_path(page.id)
  end
  
  private
    def ckeditor
      (@javascript ||= []) << '/ckeditor/ckeditor'
    end
    
    def find_page
      if @page = Page.find_by_id(params[:id])
        @current_version = params[:version].blank? ? @page.active_version : @page.find_version_number(params[:version])
      else
        render :text => 'Not Found', :status => 404
      end
    end
  
end
