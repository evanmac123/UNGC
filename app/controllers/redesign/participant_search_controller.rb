class Redesign::ParticipantSearchController < Redesign::ApplicationController

  def index
    set_current_container :highlight, '/what-is-gc/participants/directory'
    @search = Redesign::ParticipantSearchForm.new
    @page = create_page


    # @ghedamat, @benmoss: not sure this is the right way of displaying "all" participants on index. Also, needs to be sorted alphabetically by default
    @results = ParticipantSearch::ResultsPresenter.new(@search.execute)
  end

  def search
    @search = Redesign::ParticipantSearchForm.new(page, search_params)
    @page = create_page
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
