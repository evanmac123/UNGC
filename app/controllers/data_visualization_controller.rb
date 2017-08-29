class DataVisualizationController < ApplicationController

  def index
    @countries = Organization.joins(:country)
     .where(active: true)
     .group('countries.name')
     .select('countries.name', 'count(organizations.id) as organization_count')
     .flat_map do |country|
       [name: country.name, count: country.organization_count]
     end

     respond_to do |format|
      format.html
      format.json { render json: @countries }
    end
  end

end
