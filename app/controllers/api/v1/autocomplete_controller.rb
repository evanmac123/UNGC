class Api::V1::AutocompleteController < ApplicationController

  def participants
    render json: autocomplete(Organization.active.participants)
  end

  def unsigned_participants
    id = params.fetch(:initiative_id)
    organizations = Organization.unsigned_participants(id)
    render json: autocomplete(organizations, staff_only: true)
  end

  def organgzations
    render json: autocomplete(Organization.all, staff_only: true)
  end

  def events
    # Only for staff
    events = current_contact.from_ungc? ? Event.all : Event.none
    render json: AutocompleteEventQuery.new(events).search(term)
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

  def autocomplete(scope, staff_only: false)
    return scope.none if staff_only && !current_contact.from_ungc?

    AutocompleteQuery.new(scope).search(term)
  end

  def term
    params.fetch(:term, "")
  end

end
