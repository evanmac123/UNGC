class OrganizationPresenter < SimpleDelegator
  attr_reader :organization

  def initialize(organization)
    @organization = organization
  end

  def level_of_participation_view
    @organization.level_of_participation
  end

  def precise_revenue_view
    amount_in_cents = @organization.precise_revenue_cents
    if amount_in_cents.present?
       amount_in_cents / 100
    else
      'Organization has not provided exact revenue'
    end
  end

end
