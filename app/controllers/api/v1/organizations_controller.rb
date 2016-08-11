class Api::V1::OrganizationsController < ApplicationController

  def index
    organizations = Organization.all
    organization_id  = organizations.map do |organization|
      { :id => organization.id,
        :name => organization.name,
        :participant => organization.participant,
        :country_name => organization.country.name,
        :revenue => organization.revenue_description,
        :employees => organization.employees,
        :cop_state => organization.cop_state,
        :url => organization.url,
        :sector_name => organization.sector.name,
        :is_local_network_member => organization.is_local_network_member,
        :is_deleted => organization.is_deleted,
        :created_at => organization.created_at,
        :updated_at => organization.updated_at,
        :organization_type => {
            :name => organization.organization_type.name,
            :type => organization.organization_type.type_description
        }
      }
    end
    render json: organization_id
  end
end
