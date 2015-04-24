class Redesign::ParticipantSearchController < Redesign::ApplicationController

  def index
    set_current_container :highlight, '/participant-search'
    @page = create_page
    @search = ParticipantSearch::Form.new
  end

  def search
    @page = create_page
    @search = ParticipantSearch::Form.new(search_params)
    @results = ParticipantSearch::ResultsPresenter.new(@search.execute)
  end

  private

  def search_params
    # TODO change the form so we don't need this conversion
    convert_id_hashes_to_arrays(params.require(:search).slice(
      :organization_types,
      :initiatives,
      :countries
    ))
  end

  def create_page
    ParticipantSearch::Page.new(current_container, current_payload_data)
  end

  def convert_id_hashes_to_arrays(params)
    params.each_with_object({}) do |entry, memo|
      key, id_params = entry.first, entry.last
      memo[key] ||= []
      memo[key] += id_params.keys.map(&:to_i)
    end
  end

end
