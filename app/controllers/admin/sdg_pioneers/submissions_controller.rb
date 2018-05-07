class Admin::SdgPioneers::SubmissionsController < AdminController

  def index
    @submissions = SdgPioneer::Submission.where(created_at: start_date...Date.today)
    @business_leaders = @submissions.business_leader
    @submission_types = @submissions.group_by { |t| t.pioneer_type  }
  end

  def show
    @submission = SdgPioneer::Submission.find(params.fetch(:id))
  end

  private

  def start_date
    Date.new(2018,5,3)
  end

end
