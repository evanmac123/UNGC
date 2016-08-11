class Api::V1::OrganizationsController < ApplicationController

  def index
    organizations = Organization.participants.
      includes(:sector, :country, :organization_type).
      paginate(per_page: 100, page: page)
    render json: OrganizationSerializer.wrap(organizations).as_json
  end

  private

  def page
    params.fetch(:page, 1)
  end

end
