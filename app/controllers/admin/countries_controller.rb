class Admin::CountriesController < AdminController
  before_filter :no_organization_or_local_network_access

  def index
    @countries = Country.unscoped.includes([:manager, :participant_manager, :local_network]).order(order_from_params)
  end

  def new
    @country = Country.new
  end

  def edit
    @country = Country.find(params[:id])
  end

  def create
    @country = Country.new(country_params)
    if @country.save
      flash[:notice] = 'Country was successfully created.'
      redirect_to(admin_countries_path)
    else
      render :action => "new"
    end
  end

  def update
    @country = Country.find(params[:id])
    if @country.update_attributes(country_params)
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

  private

  def order_from_params
    @order = [params[:sort_field] || 'countries.name', params[:sort_direction] || 'ASC'].join(' ')
  end

  def country_params
    params.require(:country).permit(
      :code,
      :name,
      :region,
      :manager_id,
      :local_network_id,
      :regional_center_id,
      :participant_manager_id
    )
  end

end