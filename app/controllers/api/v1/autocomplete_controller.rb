class Api::V1::AutocompleteController < ApplicationController

  def participants
    render json: autocomplete(Organization.active.participants)
  end

  def sdg_pioneer_businesses
    eligible_businesses = SdgPioneer::EligibleBusinessesQuery.new.run
    render json: autocomplete(eligible_businesses)
  end

  def countries
    render json: autocomplete(Country.all)
  end

  private

  def autocomplete(scope)
    AutocompleteQuery.new(scope).search(term)
  end

  def term
    params.fetch(:term, "")
  end

end
