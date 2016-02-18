class SdgPioneer::BusinessesController < ApplicationController

  def new
    @business = SdgPioneer::Business.new
    @sdgs = SustainableDevelopmentGoal.all
  end

  def create
    @business = SdgPioneer::Business.new(business_params)

    # do we have an exact match on organization name?
    query = SdgPioneer::EligibleBusinessesQuery.new(named: @business.organization_name)
    @business.organization_name_matched = query.run.any?

    if @business.save
      redirect_to sdg_pioneer_index_path, notice: I18n.t('sdg_pioneer.nominated')
    else
      @sdgs = SustainableDevelopmentGoal.all
      render :new
    end
  end

  private

  def business_params
    params.require(:business).permit(
      :organization_name,
      :is_participant,
      :is_nominated,
      :nominating_organization,
      :nominating_individual,
      :contact_person_name,
      :contact_person_title,
      :contact_person_email,
      :contact_person_phone,
      :local_business_name,
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
