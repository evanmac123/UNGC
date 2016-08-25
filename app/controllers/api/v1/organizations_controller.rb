class Api::V1::OrganizationsController < ApplicationController

  def index
    organizations = Organization.participants.
      includes(:sector, :country, :organization_type)

    # /api/v1/organizations.json?intiative=climate
    if params[:initiative].present?
      organizations = organizations.
        joins(:signings).
        where(signings: {initiative_id: the_id })
    end

    # /api/v1/organizations.json?last_modified=1230234098
    if params[:last_modified].present?
      some_date_and_time = Time.zone.at(params[:last_modified].to_i)
      organizations = organizations.
        where("organizations.updated_at > ?", some_date_and_time)
    end

    organizations = organizations.order("organizations.updated_at desc")

    organizations = organizations.
      paginate(per_page: per_page, page: page)

    response.headers['Current-Page']  = page.to_s
    response.headers['Per-Page']      = per_page.to_s
    response.headers['Total-Entries'] = organizations.count.to_s

    render json: {
      organizations: OrganizationSerializer.wrap(organizations).as_json
    }
  end

  private

  def page
    params.fetch(:page, 1)
  end

  def per_page
    params.fetch(:per_page, 100)
  end

  def the_id
    Initiative.id_by_filter(params[:initiative])
  end

end
