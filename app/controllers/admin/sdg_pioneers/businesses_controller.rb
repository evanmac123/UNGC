class Admin::SdgPioneers::BusinessesController < AdminController

  def index
    @businesses = SdgPioneer::Business.all
  end

  def show
    @business = SdgPioneer::Business.find(params.fetch(:id))
  end

end
