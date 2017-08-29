class DataVisualization::CopsController < ApplicationController

  def index
    @countries = Country.joins(:organizations).where("organizations.participant": true).where("organizations.active": true).distinct
  end

  def show
    @country = Country.find(params.fetch(:id))
    country_cop_data = DataVisualization::CountryCopQueries.new(@country.id)
    @cop_count = country_cop_data.cop_count
    # @cop_type_count = country_cop_data.cop_type_count
    @cop_count_by_year = country_cop_data.cop_count_by_year
    @cop_count_by_month_in_year = country_cop_data.cop_count_by_month_in_year
    @cop_differentiation_count = country_cop_data.differentiation_count
    @cop_differentiation_by_year = country_cop_data.differentation_count_by_year
    @cop_differentiation_by_org_size = country_cop_data.differentiation_by_organization_size
  end

end
