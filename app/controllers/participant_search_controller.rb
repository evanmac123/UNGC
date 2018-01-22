class ParticipantSearchController < ApplicationController

  def index
    set_current_container_by_path '/what-is-gc/participants'
    @search = ParticipantSearchForm.new(page, search_params)
    @page = create_page
    @results = ParticipantSearch::ResultsPresenter.new(@search.execute)
  end

  def search
    set_current_container_by_path '/what-is-gc/participants'
    @search = ParticipantSearchForm.new(page, search_params)
    @page = create_page
    @results = ParticipantSearch::ResultsPresenter.new(@search.execute)
  end

  private

  def search_params
    search_params = params[:search] || empty_params
    search_params.permit(
      :per_page,
      :sort_field,
      :sort_direction,
      :keywords,
      organization_types: [],
      initiatives: [],
      countries: [],
      sectors: [],
      engagement_tiers: [],
      reporting_status: [],
    )
  end

  def page
    params.fetch(:page, 1).try(:to_i)
  end

  def create_page
    ParticipantSearchPage.new(current_container, current_payload_data)
  end

  def empty_params
    ActionController::Parameters.new({})
  end

end
