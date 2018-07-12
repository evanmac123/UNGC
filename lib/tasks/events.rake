namespace :events do

  desc "Create the initial import event for Organization, Contacts and LocalNetworks."
  task initial_import: :environment do
    each_in_batches(Organization) do |organization|
      event = DomainEvents::OrganizationImported.new(data: organization.attributes)
      EventPublisher.publish(event, to: "organization_#{organization.id}")
    end

    each_in_batches(Contact) do |contact|
      event = DomainEvents::ContactImported.new(data: contact.attributes)
      EventPublisher.publish(event, to: "contact_#{contact.id}")
    end

    each_in_batches(LocalNetwork) do |local_network|
      event = DomainEvents::LocalNetworkImported.new(data: local_network.attributes)
      EventPublisher.publish(event, to: "local_network_#{local_network.id}")
    end
  end

  desc "patch up Organization, Contact and LocalNetwork Updated events"
  task patch_update_events: :environment do
    patch_local_network_events
    patch_update_events("DomainEvents::ContactUpdated", "contact_")
    patch_update_events("DomainEvents::OrganizationUpdated", "organization_")
    patch_update_events("DomainEvents::LocalNetworkUpdated", "local_network_")
  end

  private

  def each_in_batches(model)
    puts model.model_name.to_s
    count = 0
    model.find_in_batches do |batch|
      count += 1
      puts "\tProcessing batch #{count}..."
      batch.each do |organization|
        yield(organization)
      end
    end
  end

  # local networks were initial created with the stream name localnetwork_123
  # this updates them to local_network_123
  def patch_local_network_events
    events = RailsEventStoreActiveRecord::Event.where("stream like 'localnetwork_%'")

    events.find_in_batches do |batch|
      batch.each do |event|
        ap "patching local_network: #{event.stream}"
        event.update!(stream: event.stream.gsub("localnetwork_", "local_network_"))
      end
    end
  end

  def patch_update_events(event_type, stream_prefix)
    events = RailsEventStoreActiveRecord::Event \
      .where(event_type: event_type)

    events.find_in_batches do |batch|
      batch.each do |event|
        id = event.stream.gsub(stream_prefix, "").to_i
        data = event.data

        unless data[:changes].key?("id")
          ap "patching #{event.stream}"
          data[:changes]["id"] ||= id
          event.update!(data: data)
        end
      end
    end
  end

end
