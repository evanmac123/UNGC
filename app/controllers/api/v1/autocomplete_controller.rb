class Api::V1::AutocompleteController < ApplicationController

  def participants
    render json: autocomplete(Organization.active.participants)
  end

  def sdg_pioneer_submissions
    eligible_businesses = SdgPioneer::EligibleBusinessesQuery.new.run
    render json: autocomplete(eligible_businesses)
  end

  def countries
    render json: autocomplete(Country.all)
  end

  def staff
    authenticate_contact!
    render json: AutocompleteContactQuery.new.search(term)
  end

  private

  def autocomplete(scope)
    AutocompleteQuery.new(scope).search(term)
  end

  def term
    params.fetch(:term, "")
  end

end
