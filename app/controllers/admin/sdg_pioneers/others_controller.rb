class Admin::SdgPioneers::OthersController < AdminController

  def index
    @others = SdgPioneer::Other.all
  end

  def show
    @other = SdgPioneer::Other.find(params.fetch(:id))
  end

end
