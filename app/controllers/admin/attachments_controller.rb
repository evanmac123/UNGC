class Admin::AttachmentsController < AdminController
  before_filter :fetch_parents

  helper_method :header_string, :cancel_string, :cancel_path,
    :attachments, :attachments_path, :new_attachment_path, :upload_attachment_path, :attachment_path

  def index
    render '/admin/attachments/index', :layout => 'admin'
  end

  def new
    render '/admin/attachments/new', :layout => 'admin'
  end

  def create
    if params[:uploaded_attachments].is_a?(Array)
      @submodel.uploaded_attachments = params[:uploaded_attachments]
      @submodel.save!
      redirect_to(attachments_path)
    else
      flash.now[:error] = 'Please select at least one file to upload.'
      render '/admin/attachments/new', :layout => 'admin'
    end
  end

  def destroy
    attachment = @submodel.attachments.find(params[:id])
    attachment.destroy
    redirect_to(attachments_path)
  end

  private

  def attachments
    @submodel.attachments
  end

  def fetch_parents
    @model    = model.find(params["#{model.name.underscore}_id"])
    @submodel = submodel.find(params["#{submodel.name.underscore}_id"])
  end

  def attachments_path(p={})
    p = {
      "controller"                     => params["controller"],
      "action"                         => :index,
      "#{model.name.underscore}_id"    => params["#{model.name.underscore}_id"],
      "#{submodel.name.underscore}_id" => params["#{submodel.name.underscore}_id"]
    }.with_indifferent_access.merge(p)

    url_for(p)
  end

  def new_attachment_path(p={})
    attachments_path({:action => :new}.merge(p))
  end

  def upload_attachment_path(p={})
    attachments_path({:action => :create}.merge(p))
  end

  def attachment_path(attachment, p={})
    attachments_path({:action => :show, :id => attachment.to_param}.merge(p))
  end
end

