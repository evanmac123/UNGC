class SdgPioneer::EligibleBusinessesQuery

  def initialize(named: nil)
    @named = named
  end

  def run
    eligible_types = OrganizationType.for_filter(:companies, :micro_enterprise, :sme)
    scope = Organization.active.participants
      .where(organization_type: eligible_types)
      .where.not(level_of_participation: nil)

    if @named.present?
      scope.where(name: @named)
    else
      scope
    end
  end

end
