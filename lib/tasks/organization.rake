namespace :organization do

  desc "Remove stale searchables"
  task clear_stale_searchables: :environment do
    sweeper = Searchable::StaleOrganizationSweeper.new
    sweeper.update_or_evict_stale_organizations
  end

  task recalculate_revenue: :environment do
    orgs = Organization.
      where.not(precise_revenue_cents: nil).
      where("updated_at >= ?", Organization::INTRODUCTION_OF_PRECISE_REVENUE).
      order(updated_at: :desc).
      reject do |o|
      calculated = RevenueCalculator.calculate_bracketed_revenue(o.precise_revenue)
      o.revenue == calculated
    end.
      map do |o|
      o.send(:set_bracketed_revenue)
      o.save!
      {
        id: o.id,
          updated_at: o.updated_at,
          precise: o.precise_revenue.format,
          revenue: "#{o.revenue_description} (#{o.revenue})",
          calculated: Organization::REVENUE_LEVELS[RevenueCalculator.calculate_bracketed_revenue(o.precise_revenue)],
      }
    end
    ap orgs
  end
end
