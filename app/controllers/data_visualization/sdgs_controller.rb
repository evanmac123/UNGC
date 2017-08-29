class DataVisualization::SdgsController < ApplicationController

  def index
    @countries = Country.joins(organizations: [communication_on_progresses: [cop_answers: [cop_attribute: [:cop_question]]]]).where(organizations: {active: true, participant: true}).where("value = 1 or cop_answers.text <> ''").where("grouping = 'sdgs'").distinct
  end

  def show
    @country = Country.find(params.fetch(:id))
    sdg_data = DataVisualization::SdgDataQueries.new(@country.id)
    @sdg_count = sdg_data.country_sdg_count
    @sdg_sector_breakdown = sdg_data.sdg_country_sector_count
  end

end
