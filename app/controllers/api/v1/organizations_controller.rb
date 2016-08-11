class Api::V1::OrganizationsController < ApplicationController

  def index
    organizations = Organization.all
    organization_id  = organizations.map do |organization|
      { :id => organization.id,
        :name => organization.name,
        :country_name => organization.country.name,
        :revenue => organization.revenue,
        :employees => organization.employees,
        :created_at => organization.created_at,
        :updated_at => organization.updated_at,
        :cop_state => organization.cop_state,
        :url => organization.url,
        :sector_id => organization.sector_id,
        :is_local_network_member => organization.is_local_network_member,
        :organization_type => organization.organization_type,
      }
    end
    render json: organization_id
  end
end
