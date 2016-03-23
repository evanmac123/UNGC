class Admin::SdgPioneers::IndividualsController < AdminController

  def index
    @individuals = SdgPioneer::Individual.all
  end

  def show
    @individual = SdgPioneer::Individual.find(params.fetch(:id))
  end

end
