class DataVisualization::ParticipantSdgsController < ApplicationController

  def index
    @participant_overall_sdg_breakdown = DataVisualization::TotalSdgsQueries.new.overall_sdg_breakdown
    @participant_overall_sdg_sector_count = DataVisualization::TotalSdgsQueries.new.overall_sdg_sector_count
    @participant_sme_sdg_breakdown = DataVisualization::TotalSdgsQueries.new.overall_sme_sdg_breakdown
    @participant_company_sdg_breakdown = DataVisualization::TotalSdgsQueries.new.overall_company_sdg_breakdown
  end
end
