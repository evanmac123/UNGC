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

  def invoice_date_view
    invoice_date = @organization.invoice_date
    invoice_date ? invoice_date : 'Organization currently has no invoice date'
  end

  def precise_revenue_view
    amount = @organization.precise_revenue
    if amount.nil?
      'Organization has not provided a revenue'
    else
      amount.format
    end
  end

end