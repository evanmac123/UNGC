class Redesign::SearchController < Redesign::ApplicationController

  def search
    @resuts = SitewideSearch.new(search_params).execute
  end

  private

  def search_params
    params.require(:s)
  end

  class SitewideSearch

    def execute
    end

  end

end
