class DataVisualizationController < ApplicationController

  def index
    @countries = Country
      .joins(:organizations)
      .where(organizations: { active: true })
      .group(:name, :id)
      .select('countries.name', 'count(*) as organization_count')
     .flat_map do |country|
       [name: country.name, count: country.organization_count]
     end

     respond_to do |format|
      format.html
      format.json { render json: @countries }
    end
  end

end
