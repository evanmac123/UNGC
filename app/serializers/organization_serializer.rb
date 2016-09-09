class OrganizationSerializer < ApplicationSerializer

  def attributes
    {
      id: organization.id,
      name: organization.name,
      participant: organization.participant,
      country_name: organization.country_name,
      revenue: organization.revenue_description,
      employees: organization.employees,
      cop_state: organization.cop_state,
      url: organization.url,
      sector_name: organization.sector_name,
      profile_url: participant_url(organization),
      is_local_network_member: organization.is_local_network_member,
      is_deleted: organization.is_deleted,
      created_at: organization.created_at,
      updated_at: organization.updated_at,
      organization_type: {
        name: organization.organization_type.name,
        type: organization.organization_type.type_description
      }
    }
  end

  alias_method :organization, :object

end
