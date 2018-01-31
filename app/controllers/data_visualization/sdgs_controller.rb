class DataVisualization::SdgsController < ApplicationController

  def index
  end

  def global
    global = DataVisualization::SdgGlobalQueries.new
    @global_total = global.overall_sdg_breakdown
    @global_sector = global.overall_sdg_sector_count
  end

  def regions
    @regions = Country.group(:region).select(:region).reorder(:region).pluck(:region)
  end

  def region
    @region = params.fetch(:region)
    sdg_region_data = DataVisualization::SdgRegionQueries.new(@region)
    @sdg_region_count = sdg_region_data.sdg_region_count
    @sdg_region_sector = sdg_region_data.sdg_region_sector_count
  end

  def countries
    @countries = Country
        .joins(organizations: [communication_on_progresses: [cop_answers: [cop_attribute: [:cop_question]]]])
        .where(organizations: {active: true, participant: true})
        .where("value = :val or cop_answers.text > ''", val: true)
        .where(cop_questions: { grouping: :sdgs })
        .distinct
  end

  def country
    @country = Country.find(params.fetch(:id))
    sdg_country_data = DataVisualization::SdgCountryQueries.new(@country.id)
    @sdg_count = sdg_country_data
                     .country_sdg_count

    @sdg_sector_breakdown = sdg_country_data
                                .sdg_country_sector_count
                                .reorder('cop_attributes.position')

  end

end
