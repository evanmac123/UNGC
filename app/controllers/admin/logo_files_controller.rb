class Admin::LogoFilesController < AdminController
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
    @logo_file = LogoFile.new(params[:logo_file])
    if @logo_file.save
      flash[:notice] = 'Logo File was successfully created.'
      redirect_to(admin_logo_files_path)
    else
      render :action => "new"
    end
  end

  def update
    @logo_file = LogoFile.find(params[:id])
    if @logo_file.update_attributes(params[:logo_file])
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
end
