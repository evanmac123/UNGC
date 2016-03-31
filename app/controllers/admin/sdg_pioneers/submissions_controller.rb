class Admin::SdgPioneers::SubmissionsController < AdminController

  def index
    @submissions = SdgPioneer::Submission.all
    @submission_type = @submissions.group_by { |t| t.pioneer_type }
  end

  def show
    @submission = SdgPioneer::Submission.find(params.fetch(:id))
  end

end
