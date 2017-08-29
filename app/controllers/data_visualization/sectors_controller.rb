class DataVisualization::SectorsController < ApplicationController

  def index
    @countries = Country.joins(organizations: [:sector]).where("organizations.participant": true).where("organizations.active": true).where("sectors.name != ?", 'Not Applicable').distinct
  end

  def show
    @country = Country.find(params.fetch(:id))
    business_sector_data = DataVisualization::SectorDataQueries.new(@country.id)
    @business_sector_count = business_sector_data.business_sectors_in_country
    @business_sector_growth = business_sector_data.business_sector_growth_mapping
  end

end
