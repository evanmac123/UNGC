class Admin::SdgPioneers::OthersController < AdminController

  def index
    @others = SdgPioneer::Other.where(created_at: start_date...Date.today)
  end

  def show
    @other = SdgPioneer::Other.find(params.fetch(:id))
  end

  private

  def start_date
    Date.new(2018,5,3)
  end

end
