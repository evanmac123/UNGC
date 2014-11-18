class Admin::LogoFilesController < AdminController
  before_filter :no_organization_or_local_network_access

  def index
    @logo_files = LogoFile.all
  end

  def new
    @logo_file = LogoFile.new
  end

  def edit
    @logo_file = LogoFile.find(params[:id])
  end

  def create
    @logo_file = LogoFile.new(file_params)
    if @logo_file.save
      flash[:notice] = 'Logo File was successfully created.'
      redirect_to(admin_logo_files_path)
    else
      render :action => "new"
    end
  end

  def update
    @logo_file = LogoFile.find(params[:id])
    if @logo_file.update_attributes(file_params)
      flash[:notice] = 'Logo File was successfully updated.'
      redirect_to(admin_logo_files_path)
    else
      render :action => "edit"
    end
  end

  def destroy
    @logo_file = LogoFile.find(params[:id])
    @logo_file.destroy
    redirect_to(admin_logo_files_path)
  end

  private

  def file_params
    params.fetch(:logo_file, {}).permit(
      :name,
      :description,
      :thumbnail,
      :file,
      :zip,
      :preview
    )
  end

end
