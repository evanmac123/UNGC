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
    # TODO these are wrong
    params.require(:submission).permit(
      :organization_name,
      :is_participant,
      :is_nominated,
      :nominating_organization,
      :nominating_individual,
      :contact_person_name,
      :contact_person_title,
      :contact_person_email,
      :contact_person_phone,
      :local_submission_name,
      :website_url,
      :country_name,
      :local_network_status,
      :positive_outcomes,
      :other_relevant_info,
      :accepts_tou,
      matching_sdgs: [],
      uploaded_positive_outcome_attachments: [:attachment],
      uploaded_societal_effect_attachments: [:attachment],
    )
  end

end
