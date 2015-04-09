class Redesign::ParticipantSearchController < Redesign::ApplicationController

  def index
    set_current_container :highlight, '/participant-search'
    @page = create_page
    @search = ParticipantSearch::Presenter.new
  end

  def search
    @page = create_page
    search = ParticipantSearch::Form.new(search_params)
    @search = ParticipantSearch::ResultsPresenter.new(search, search.execute)
  end

  private

  def search_params
    params.require(:search).permit(:organization_type)
  end

  def create_page
    ParticipantSearch::Page.new(current_container, current_payload_data)
  end

end
