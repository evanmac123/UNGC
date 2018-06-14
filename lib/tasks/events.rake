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

end
