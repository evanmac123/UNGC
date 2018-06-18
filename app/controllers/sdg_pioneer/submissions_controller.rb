class SdgPioneer::SubmissionsController < ApplicationController

  def new
    @submission = SdgPioneer::Submission.new
    @sdgs = SustainableDevelopmentGoal.all
  end

  def create
    @submission = SdgPioneer::Submission.new(submission_params)

    if @submission.save
      redirect_to sdg_pioneer_index_path, notice: I18n.t('sdg_pioneer.nominated')
    else
      @sdgs = SustainableDevelopmentGoal.all
      render :new
    end
  end

  private

  def submission_params
    params.require(:submission).permit(
      :company_success,
      :innovative_sdgs,
      :ten_principles,
      :awareness_and_mobilize,
      :name,
      :title,
      :email,
      :phone,
      :organization_name,
      :organization_id,
      :country_name,
      :accepts_tou,
      :accepts_interview,
      :local_network_question,
      :has_local_network,
      :is_participant,
      :website_url,
      matching_sdgs: [],
      uploaded_supporting_documents: [:attachment],
    )
  end

end
