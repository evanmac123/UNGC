class SdgPioneer::SubmissionsController < ApplicationController

  def new
    @submission = SdgPioneer::Submission.new
    @sdgs = SustainableDevelopmentGoal.all
  end

  def create
    @submission = SdgPioneer::Submission.new(submission_params)

    # do we have an exact match on organization name?
    query = SdgPioneer::EligibleBusinessesQuery.new(named: @submission.organization_name)
    @submission.organization_name_matched = query.run.any?

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
      :pioneer_type,
      :company_success,
      :innovative_sdgs,
      :ten_principles,
      :awareness_and_mobilize,
      :name,
      :title,
      :email,
      :phone,
      :organization_name,
      :organization_name_matched,
      :country_name,
      :accepts_tou,
      :is_participant,
      :website_url,
      matching_sdgs: [],
      uploaded_supporting_documents: [:attachment],
    )
  end

end
