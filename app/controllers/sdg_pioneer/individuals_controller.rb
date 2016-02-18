class SdgPioneer::IndividualsController < ApplicationController

  def new
    @individual = SdgPioneer::Individual.new
    @sdgs = SustainableDevelopmentGoal.all
  end

  def create
    @individual = SdgPioneer::Individual.new(individual_params)

    if @individual.save
      redirect_to sdg_pioneer_index_path, notice: I18n.t('sdg_pioneer.nominated')
    else
      @sdgs = SustainableDevelopmentGoal.all
      render :new
    end
  end

  private

  def individual_params
    params.require(:individual).permit(
      :is_nominated,
      :nominating_organization,
      :nominating_individual,
      :name,
      :title,
      :email,
      :phone,
      :organization_name,
      :local_business_nomination_name,
      :is_participant,
      :country_name,
      :local_network_status,
      :website_url,
      :description_of_individual,
      :other_relevant_info,
      :accepts_tou,
      matching_sdgs: [],
      uploaded_supporting_documents: [:attachment],
    )
  end

end
