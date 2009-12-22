class Admin::CountriesController < AdminController
  def index
    @countries = Country.all
  end

  def new
    @country = Country.new
  end

  def edit
    @country = Country.find(params[:id])
  end

  def create
    @country = Country.new(params[:country])
    if @country.save
      flash[:notice] = 'Country was successfully created.'
      redirect_to(admin_countries_path)
    else
      render :action => "new"
    end
  end

  def update
    @country = Country.find(params[:id])
    if @country.update_attributes(params[:country])
      flash[:notice] = 'Country was successfully updated.'
      redirect_to(admin_countries_path)
    else
      render :action => "edit"
    end
  end

  def destroy
    @country = Country.find(params[:id])
    @country.destroy
    redirect_to(admin_countries_path)
  end
end