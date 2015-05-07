class Redesign::ParticipantSearchController < Redesign::ApplicationController

  def index
    set_current_container :highlight, '/what-is-gc/participants/directory'
    @page = create_page
    @search = Redesign::ParticipantSearchForm.new
    @results = []
  end

  def search
    @page = create_page
    @search = Redesign::ParticipantSearchForm.new(page, search_params)
    @results = ParticipantSearch::ResultsPresenter.new(@search.execute)
  end

  private

  def search_params
    params.fetch(:search, {}).permit(
      :per_page,
      :sort_field,
      :keywords,
      organization_types: [],
      initiatives: [],
      countries: [],
      sectors: [],
      reporting_status: [],
    )
  end

  def page
    params.fetch(:page, 1)
  end

  def create_page
    ParticipantSearchPage.new(current_container, current_payload_data)
  end

end
