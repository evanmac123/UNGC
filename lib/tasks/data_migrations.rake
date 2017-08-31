namespace :data do

  desc "rename LocalNetwork states"
  task rename_local_network_states: :environment do
    LocalNetwork.transaction do
      puts LocalNetwork.where(state: 'Established').update_all(state: 'Active')
      puts LocalNetwork.where(state: 'Formal').update_all(state: 'Advanced')
    end
  end

  desc "Backfill the Searchables table with delisted organizations"
  task backfill_searchables_with_delisted_organizations: :environment do
    searchable = Searchable::SearchableOrganization
    inactive = searchable.all.where.not(active: true)
    Searchable.index_searchable(searchable, inactive)
  end

  desc "Fix donation stream names"
  task fix_donation_event_stream_names: :environment do
    class EventStoreEvent < ActiveRecord::Base; end

    fixed = 0
    EventStoreEvent.
      where(event_type: "Donation::CreatedEvent").each do |event|
      data = YAML.load(event.data)
      if event.stream == "donations"
        stream_name= "donation_#{data.fetch(:donation_id)}"
        event.update!(stream: stream_name)
        fixed += 1
      end
    end

    puts "Fixed #{fixed} Events."
  end

end
