class Admin::SdgPioneers::SubmissionsController < AdminController

  def index
    @submissions = SdgPioneer::Submission.all
  end

  def show
    @submission = SdgPioneer::Submission.find(params.fetch(:id))
  end

end
