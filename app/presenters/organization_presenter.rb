# frozen_string_literal: true

class OrganizationPresenter < SimpleDelegator
  attr_reader :organization, :policy

  delegate \
    :can_edit_video?,
    :can_edit_exclusionary_criteria?,
    to: :policy

  def initialize(organization, contact)
    super(organization)
    @organization = organization
    @policy = Organization::Policy.new(organization, contact)
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

  def parent_company_name
    @organization.parent_company&.name
  end

  def action_platform_subscriptions
    @organization
        .action_platform_subscriptions
        .joins(:platform, :order, :contact)
        .includes(:platform, :order, :contact)
        .order(starts_on: :desc, platform_id: :asc)
  end

  def should_show_exclusionary_criteria?
    @policy.can_view_exclusionary_criteria?
  end

end
