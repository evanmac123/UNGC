class OrganizationPresenter < SimpleDelegator
  attr_reader :organization

  def initialize(organization)
    super(organization)
    @organization = organization
  end

  def level_of_participation_view
    level_of_participation = @organization.level_of_participation
    level_of_participation ? level_of_participation : 'Level of engagement is not selected'
  end

  def precise_revenue_view
    amount = @organization.precise_revenue_cents
    if amount.nil?
      'Organization has not provided a revenue'
    else
      dollar_amount(amount)
    end
  end

  def dollar_amount(amount)
    amount / 100
  end

end
