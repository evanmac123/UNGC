class Admin::SdgPioneers::SubmissionsController < AdminController

  def index
    @submissions = SdgPioneer::Submission.all
    @business_leaders = @submissions.business_leader
    @submission_types = @submissions.group_by { |t| t.pioneer_type  }
  end

  def show
    @submission = SdgPioneer::Submission.find(params.fetch(:id))
  end

end
