class LocalNetworkEventSearch < OpenStruct
  def results
    @results ||= perform_search
  end

  def perform_search
    conditions = []
    args = []

    if start_date.present?
      conditions << 'local_network_events.date > ?'
      args << start_date
    end

    if end_date.present?
      conditions << 'local_network_events.date < ?'
      args << end_date
    end

    if event_type.present?
      conditions << 'local_network_events.event_type = ?'
      args << event_type
    end

    if principle_id.present?
      conditions << 'local_network_events_principles.principle_id = ?'
      args << principle_id
    end

    if region.present?
      conditions << 'countries.region = ?'
      args << region
    end

    if local_network_id.present?
      conditions << 'local_network_events.local_network_id = ?'
      args << local_network_id
    end

    LocalNetworkEvent.paginate :page => page, :per_page => per_page,
      :joins => %{
        LEFT JOIN local_network_events_principles ON local_network_events_principles.local_network_event_id = local_network_events.id
        LEFT JOIN local_networks ON local_networks.id = local_network_events.local_network_id
        LEFT JOIN countries ON countries.local_network_id = local_networks.id
      }.gsub(/\s+/, ' '),
      :group => 'local_network_events.id',
      :conditions => [conditions.join(' AND '), *args]
  end
end

