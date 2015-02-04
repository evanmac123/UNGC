class Admin::PagesController < AdminController
  before_filter :no_organization_or_local_network_access
  before_filter :only_website_editors, :only => :index
  before_filter :find_page, :only => [:approve, :check, :edit, :delete, :destroy, :rename, :revoke, :show, :update]

  def index
    respond_to do |wants|
      wants.html { }
      wants.json { }
    end
  end

  def pending
    @section = 'pending'
    render action: 'index'
  end

  def show
    respond_to do |wants|
      wants.js {
        render(:update) { |page|
          page['#pageArea'].html(render partial: 'page_area')
        }
      }
      wants.html { render inline: '' }
    end
  end

  def new
    defaults = {:path => (params[:section] || '/') + 'untitled.html'}
    @page = Page.new defaults.merge(params[:page] || {})
  end

  def create
    @page = Page.new params[:page]
    if @page.save
      respond_to do |wants|
        wants.html { flash[:notice] = "Page successfully created"; redirect_to :action => 'index' }
        wants.js   { render json: @page }
      end
    else
      render :action => 'new'
    end
  end

  def create_folder
    folder = PageGroup.create(name: params[:name])
    respond_to do |format|
      format.js { render json: folder }
    end
  end

  def destroy
    @page.destroy
    redirect_to :action => 'index'
  end

  def approve
    @page.as_user(current_contact).approve!
    redirect_to :action => 'index'
  end

  def rename
    if @page.rename(params[:title])
      respond_to do |wants|
        wants.js { head :ok }
      end
    else
      respond_to do |wants|
        wants.js { head :bad_request }
      end
    end
  end

  # FIXME there is no route to this action.
  def revoke
    @page.as_user(current_contact).revoke!
    redirect_to :action => 'index'
  end

  def edit
    @show_approve_button = true if current_contact.is? Role.website_editor
    if request.xhr?
      render :json => {
        :page => {
          :url => update_page_url(:format => 'js'),
          :startupMode => @current_version.dynamic_content? ? 'source' : 'wysiwyg',
          :content => @current_version.content
        }
      }
      return
    end
  end

  def check
    if @page.wants_to_change_path_and_can?(params[:page])
      update_successful
    else
      update_failed(:forbidden)
    end
  end

  def update
    begin
      @version = @page.update_pending_or_new_version(content_params)
    rescue Page::PathCollision => e
      update_failed(:forbidden, is_live_editor)
    rescue Exception => e
      logger.error "*** ERROR on PagesController#update: #{e.inspect}"
      update_failed(:bad_request, is_live_editor)
    else
      update_successful(is_live_editor)
    end
  end

  def update_failed(error_type, is_live_editor=nil)
    js_handler = head error_type
    if is_live_editor
      respond_to do |wants|
        wants.js { js_handler }
      end
    else
      respond_to do |wants|
        wants.html { render action: 'edit' }
        wants.js   { js_handler }
      end
    end
  end

  def update_successful(is_live_editor=nil)
    approve_after_update if params[:approved]
    if is_live_editor
      respond_to do |wants|
        wants.html { redirect_to view_page_url(:path => @version.to_path) } # redirect to regular page view
        wants.js   { render :json => { :page => {:content => @version.content, :version => @version.version_number} } }
      end
    else
      respond_to do |wants|
        wants.html { redirect_to edit_admin_page_path(:id => @version) } # redirect to admin editor page view
        wants.js   { render json: @version }
      end
    end
  end

  def save_tree
    PageGroup.import_tree(params[:tree], params[:deleted], params[:hidden], params[:shown])
    render :inline => ''
  end

  def find_by_path_and_redirect_to_latest
    page = Page.all_versions_of(params[:path]).last
    redirect_to edit_admin_page_path(page.id)
  end

  private

  def only_website_editors
    unless current_contact.is? Role.website_editor
      flash[:error] = "You do not have permission to access that resource."
      redirect_to dashboard_path
    end
  end

  def approve_after_update
    @version.approve! if @version.can_approve?
  end

  def find_page
    if @page = Page.find_by_id(params[:id])
      @current_version = params[:version].blank? ? @page.active_version : @page.find_version_number(params[:version])
    else
      render :text => 'Not Found', :status => 404
    end
  end

  def is_live_editor
    @is_live_editor ||= params.has_key?(:content)
  end

  def content_params
    if is_live_editor
      content = params.require(:content)
    elsif params[:page].present?
      content = params.require(:page)
    else
      return {}
    end

    content.permit(
      :path,
      :title,
      :html_code,
      :content,
      :parent_id,
      :position,
      :display_in_navigation,
      :dynamic_content,
      :version_number,
      :group_id,
      :top_level,
      :change_path,
    )
  end

end
