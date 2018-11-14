namespace :organization do

  desc "Remove stale searchables"
  task clear_stale_searchables: :environment do
    sweeper = Searchable::StaleOrganizationSweeper.new
    sweeper.update_or_evict_stale_organizations
  end

  task missing_bracketed_revenue: :environment do
    Organization::RevenueMismatch.new.missing_bracketed_revenue
  end

  task joined_since_precise_revenue: :environment do
    Organization::RevenueMismatch.new.joined_since_precise_revenue
  end

  task updated_since_precise_revenue: :environment do
    Organization::RevenueMismatch.new.updated_since_precise_revenue
  end

  task revenue_mismatch: :environment do
    Organization::RevenueMismatch.new.revenue_mismatch
  end

  task :update_participant_managers do
    CSV.open("updated_participant_managers.xls", 'w+', :col_sep => "\t") do |line|
      line << [
        "Org ID",
        "Organization Name",
        "Old PM",
        "New PM",
      ]
      Organization.joins(:participant_manager, country: :participant_manager)
        .where("organizations.participant_manager_id != countries.participant_manager_id")
        .each_with_index do |organization, index|
          old_name = organization.participant_manager.name,
          new_name = organization.country.participant_manager.name

          puts "#{index}: #{old_name} => #{new_name}"

          organization.participant_manager = organization.country.participant_manager
          organization.save!(validate: false)

          line << [
            organization.id,
            organization.name,
            old_name,
            new_name,
          ]
      end
    end
  end

end
