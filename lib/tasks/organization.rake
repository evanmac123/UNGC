namespace :organization do

  desc "Remove stale searchables"
  task clear_stale_searchables: :environment do
    sweeper = Searchable::StaleOrganizationSweeper.new
    sweeper.update_or_evict_stale_organizations
  end

  task recalculate_revenue: :environment do
  end

  task missing_bracketed_revenue: :environment do
    Organization
      .where.not(precise_revenue_cents: nil)
      .where(revenue: nil)
      .order(updated_at: :desc)
      .reject(&method(:equal_revenue))
      .tap(&method(:format))
      .map(&method(:recalculate))
  end

  task joined_since_precise_revenue: :environment do
    Organization
      .where.not(precise_revenue_cents: nil)
      .where("joined_on >= ?", Organization::INTRODUCTION_OF_PRECISE_REVENUE)
      .order(updated_at: :desc)
      .reject(&method(:equal_revenue))
      .tap(&method(:format))
      .map(&method(:recalculate))
  end

  task updated_since_precise_revenue: :environment do
    Organization
      .where.not(precise_revenue_cents: nil)
      .where("updated_at >= ?", Organization::INTRODUCTION_OF_PRECISE_REVENUE)
      .order(updated_at: :desc)
      .reject(&method(:equal_revenue))
      .tap(&method(:format))
      .map(&method(:recalculate))
  end

  task revenue_mismatch: :environment do
    # Don't try to fix these
    Organization
      .where.not(precise_revenue_cents: nil)
      .order(updated_at: :desc)
      .reject(&method(:equal_revenue))
      .tap(&method(:format))
  end

  private

  def equal_revenue(organization)
    precise_revenue = organization.precise_revenue
    calculated = RevenueCalculator.calculate_bracketed_revenue(precise_revenue)
    organization.revenue == calculated
  end

  def recalculate(organization)
    organization.send(:set_bracketed_revenue)
    organization.save!
  end

  def format(organizations)
    formatted = organizations.map do |organization|
      precise_revenue = organization.precise_revenue
      calculated = RevenueCalculator.calculate_bracketed_revenue(precise_revenue)
      {
        id: organization.id,
        updated_at: organization.updated_at,
        precise: organization.precise_revenue.format,
        revenue: "#{organization.revenue_description} (#{organization.revenue})",
        calculated: calculated,
      }
    end
    ap(formatted)
  end

end
