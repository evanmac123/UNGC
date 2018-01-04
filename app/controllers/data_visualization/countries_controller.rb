class DataVisualization::CountriesController < ApplicationController

  def index
    @countries = Country.all
  end

  def show
    @country = Country.find(params.fetch(:id))
    @top_5_sectors = Top5Sectors.for_country(@country.id)
  end

  class Top5Sectors

    def self.for_country(country_id)
      result = Sector
        .applicable
        .joins(organizations: :country)
        .includes(organization: :country)
        .where(organizations: { country_id: country_id })
        .group(:name, :id)
        .reorder('count(sectors.name) desc')
        .limit(5)
        .count

      result.map do |sector, count|
        { sector: sector, count: count }
      end
    end


  end

end
